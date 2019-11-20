class Myhtml::EncodingConverter
  BUFFER_SIZE       = 4 * 1024
  REPLACEMENT_BYTES = "\xEF\xBF\xBD"

  @to : LibEncoding::DataT
  @from : LibEncoding::DataT
  @encoder : LibEncoding::EncodeT
  @decoder : LibEncoding::DecodeT
  @replace_str : String?
  @outbuf : Pointer(UInt8)
  @codepoints_buffer : Pointer(LibEncoding::CodepointT)

  @replace_chars : Pointer(UInt32)?
  @replace_chars_size = 1
  @replace_single_codepoint = 0xFFFD_u32

  def self.new(from : LibEncoding::EncodingT | String, to : LibEncoding::EncodingT | String, replace_str : String? = nil)
    from = if from.is_a?(String)
             LibEncoding.data_by_pre_name(from, from.bytesize)
           else
             LibEncoding.data(from)
           end

    to = if to.is_a?(String)
           LibEncoding.data_by_pre_name(to, to.bytesize)
         else
           LibEncoding.data(to)
         end

    new(from, to, replace_str)
  end

  def initialize(@from : LibEncoding::DataT, @to : LibEncoding::DataT, @replace_str : String? = nil)
    if @from.null?
      raise ArgumentError.new("Unknown from encoding")
    end

    if @to.null?
      raise ArgumentError.new("Unknown to encoding")
    end

    @encoder = Pointer(Void).malloc(LibEncoding.encode_t_sizeof).as(LibEncoding::EncodeT)
    @decoder = Pointer(Void).malloc(LibEncoding.decode_t_sizeof).as(LibEncoding::DecodeT)

    @outbuf = Pointer(UInt8).malloc(BUFFER_SIZE)
    @codepoints_buffer = Pointer(LibEncoding::CodepointT).malloc(BUFFER_SIZE)

    if replace_str = @replace_str
      case replace_str.bytesize
      when 0
        @replace_chars_size = 0
      when 1
        @replace_single_codepoint = replace_str.to_unsafe[0].to_u32
        @replace_chars_size = 1
      else
        chars = replace_str.chars
        rc = @replace_chars = Pointer(UInt32).malloc(chars.size)
        chars.each_with_index do |char, i|
          rc[i] = char.ord.to_u32!
        end
        @replace_chars_size = chars.size
      end
    end

    @finished = false
    initialize_convert
  end

  private def initialize_convert
    status = LibEncoding.decode_init(@decoder, @from, @codepoints_buffer, BUFFER_SIZE)
    if status != Lib::StatusT::LXB_STATUS_OK
      raise LibError.new("Failed to initialize encoder: #{status}")
    end

    status = if replace_chars = @replace_chars
               LibEncoding.decode_replace_set(@decoder, replace_chars.as(LibEncoding::CodepointT*), @replace_chars_size)
             else
               LibEncoding.decode_replace_set(@decoder, pointerof(@replace_single_codepoint).as(LibEncoding::CodepointT*), @replace_chars_size)
             end
    if status != Lib::StatusT::LXB_STATUS_OK
      raise LibError.new("Failed to set replacement code point for decoder #{status}")
    end

    status = LibEncoding.encode_init(@encoder, @to, @outbuf, BUFFER_SIZE)
    if status != Lib::StatusT::LXB_STATUS_OK
      raise LibError.new("Failed to initialize encoder #{status}")
    end

    status = if replace_str = @replace_str
               LibEncoding.encode_replace_set(@encoder, replace_str.to_unsafe, replace_str.bytesize)
             else
               if LibEncoding.data_encoding(@to) == LibEncoding::EncodingT::LXB_ENCODING_UTF_8
                 LibEncoding.encode_replace_set(@encoder, REPLACEMENT_BYTES, REPLACEMENT_BYTES.bytesize)
               else
                 LibEncoding.encode_replace_set(@encoder, "?".to_unsafe, 1)
               end
             end

    if status != Lib::StatusT::LXB_STATUS_OK
      raise LibError.new("Failed to set replacement bytes for encoder #{status}")
    end

    @finished = false
  end

  private def convert_buffer(buffer : Slice)
    buffer_ref = buffer.to_unsafe

    loop do
      decode_status = LibEncoding.data_call_decode(@from, @decoder, pointerof(buffer_ref), buffer_ref + buffer.size)

      cp_ref = @codepoints_buffer
      cp_end = @codepoints_buffer + LibEncoding.decode_buf_used(@decoder)

      loop do
        encode_status = LibEncoding.data_call_encode(@to, @encoder, pointerof(cp_ref), cp_end)

        if encode_status == Lib::StatusT::LXB_STATUS_ERROR
          cp_ref += 1
          encode_status = Lib::StatusT::LXB_STATUS_SMALL_BUFFER
        end

        size = LibEncoding.encode_buf_used(@encoder)
        if size != 0
          yield Slice.new(@outbuf, size)
        end

        LibEncoding.encode_buf_used_set(@encoder, 0)
        break unless encode_status == Lib::StatusT::LXB_STATUS_SMALL_BUFFER
      end

      LibEncoding.decode_buf_used_set(@decoder, 0)
      break unless decode_status == Lib::StatusT::LXB_STATUS_SMALL_BUFFER
    end
  end

  private def finish_decode!
    LibEncoding.decode_finish(@decoder)
    size = LibEncoding.decode_buf_used(@decoder)
    if size != 0
      cp_ref = @codepoints_buffer
      cp_end = @codepoints_buffer + size

      LibEncoding.data_call_encode(@to, @encoder, pointerof(cp_ref), cp_end)

      size = LibEncoding.encode_buf_used(@encoder)
      if size != 0
        yield Slice.new(@outbuf, size)
      end
    end
  end

  private def finish_encode!
    LibEncoding.encode_finish(@encoder)
    size = LibEncoding.encode_buf_used(@encoder)
    if size != 0
      yield Slice.new(@outbuf, size)
    end
  end

  def convert(io : IO)
    initialize_convert if @finished

    buf = uninitialized UInt8[EncodingConverter::BUFFER_SIZE]
    slice = Slice.new(buf.to_unsafe, EncodingConverter::BUFFER_SIZE)

    loop do
      size = io.read(slice)
      break if size == 0
      convert_buffer(Slice.new(slice.to_unsafe, size)) { |out_slice| yield(out_slice) }
    end

    finish_decode! { |out_slice| yield(out_slice) }
    finish_encode! { |out_slice| yield(out_slice) }

    @finished = true
    self
  end

  def convert(io : IO) : String
    bytesize = 0
    String.build do |buf|
      convert(io) { |slice| buf.write(slice); bytesize += slice.bytesize }
      {bytesize, 0}
    end
  end

  def convert(s : String)
    convert(IO::Memory.new(s)) { |slice| yield slice }
    self
  end

  def convert(s : String) : String
    bytesize = 0
    String.build((s.bytesize * 1.2).to_i) do |buf|
      convert(s) { |slice| buf.write(slice); bytesize += slice.bytesize }
      {bytesize, 0}
    end
  end

  def convert(s : Slice)
    convert(IO::Memory.new(s)) { |slice| yield slice }
    self
  end

  def convert(s : Slice) : String
    bytesize = 0
    String.build((s.bytesize * 1.2).to_i) do |buf|
      convert(s) { |slice| buf.write(slice); bytesize += slice.bytesize }
      {bytesize, 0}
    end
  end
end
