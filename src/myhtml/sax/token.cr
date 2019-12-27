# Html token without processing (raw attribute keys, html entities not converted)
struct Myhtml::SAX::Token
  # :nodoc:
  getter tokenizer : Tokenizer

  # :nodoc:
  getter raw_tree : Lib::MyhtmlTreeT*

  # :nodoc:
  getter raw_token : Lib::MyhtmlTokenNodeT*

  def initialize(@tokenizer, @raw_tree, @raw_token)
  end

  def self.from_raw(tokenizer, raw_tree, raw_token) : Token?
    unless raw_token.null?
      Token.new(tokenizer, raw_tree, raw_token)
    end
  end

  def tag_text_slice
    pos_to_slice raw_position
  end

  def each_attribute(&block)
    each_raw_attribute do |attr|
      key = IgnoreCaseData.new(pos_to_slice(attr_key_pos(attr)))
      value = pos_to_slice(attr_value_pos(attr))
      yield key, value
    end
  end

  def attribute_by(string : String)
    kk = IgnoreCaseData.new(string)
    each_attribute do |k, v|
      return String.new(v) if k == kk
    end
  end

  def attribute_by(slice : Slice(UInt8))
    kk = IgnoreCaseData.new(slice)
    each_attribute do |k, v|
      return v if k == kk
    end
  end

  def attributes
    @attributes ||= begin
      res = {} of String => String
      each_attribute do |k, v|
        res[k.to_s] = String.new(v)
      end
      res
    end
  end

  # :nodoc:
  @attributes : Hash(String, String)?

  @[AlwaysInline]
  def self_closed?
    Lib.token_node_is_close_self(@raw_token)
  end

  @[AlwaysInline]
  def closed?
    Lib.token_node_is_close(@raw_token)
  end

  @[AlwaysInline]
  def tag_id
    Lib.token_node_tag_id(@raw_token)
  end

  @[AlwaysInline]
  def tag_sym : Symbol
    Utils::TagConverter.id_to_sym(tag_id)
  end

  @[AlwaysInline]
  def tag_name_slice
    res = Lib.tag_name_by_id(@raw_tree, tag_id, out length)
    Slice.new(res, length)
  end

  @[AlwaysInline]
  def tag_name
    String.new(tag_name_slice)
  end

  @[AlwaysInline]
  def tag_text
    String.new(tag_text_slice)
  end

  def each_raw_attribute(&block)
    attr = Lib.token_node_attribute_first(@raw_token)
    while !attr.null?
      yield attr
      attr = Lib.attribute_next(attr)
    end
  end

  @[AlwaysInline]
  def any_attribute?
    !Lib.token_node_attribute_first(@raw_token).null?
  end

  #
  # Token Inspect
  #   puts node.inspect # => Myhtml::SAX::Token(div, {"class" => "aaa"})
  #
  def inspect(io : IO)
    io << "Myhtml::SAX::Token("
    io << '/' if closed?
    io.write(tag_name_slice)
    io << '/' if self_closed?

    if textable?
      io << ", "
      Utils::Strip.string_slice_to_io_limited(tag_text_slice, io)
    else
      _attributes = @attributes

      if _attributes || any_attribute?
        io << ", {"
        c = 0
        if _attributes
          _attributes.each do |key, value|
            io << ", " unless c == 0
            Utils::Strip.string_slice_to_io_limited(key.to_slice, io)
            io << " => "
            Utils::Strip.string_slice_to_io_limited(value.to_slice, io)
            c += 1
          end
        else
          each_attribute do |key_slice, value_slice|
            io << ", " unless c == 0
            Utils::Strip.string_slice_to_io_limited(key_slice.to_s.to_slice, io)
            io << " => "
            Utils::Strip.string_slice_to_io_limited(value_slice, io)
            c += 1
          end
        end
        io << '}'
      end
    end

    io << ')'
  end

  def textable?
    case tag_id
    when Lib::MyhtmlTags::MyHTML_TAG__TEXT,
         Lib::MyhtmlTags::MyHTML_TAG__COMMENT,
         Lib::MyhtmlTags::MyHTML_TAG_STYLE
      true
    else
      false
    end
  end

  def pre_tag_slice
    rp = raw_position
    ep = element_position
    pos_to_slice(ep.start, rp.start - ep.start)
  end

  def post_tag_slice
    rp = raw_position
    ep = element_position
    pos_to_slice(rp.start + rp.length, ep.start + ep.length - (rp.start + rp.length))
  end

  @[AlwaysInline]
  private def raw_position
    Myhtml::Lib.token_node_raw_position(@raw_token)
  end

  @[AlwaysInline]
  private def element_position
    Myhtml::Lib.token_node_element_pasition(@raw_token)
  end

  @[AlwaysInline]
  private def attr_key_pos(attr)
    Myhtml::Lib.attribute_key_raw_position(attr)
  end

  @[AlwaysInline]
  private def attr_value_pos(attr)
    Myhtml::Lib.attribute_value_raw_position(attr)
  end

  @[AlwaysInline]
  private def pos_to_slice(start, size)
    buf = Myhtml::Lib.incoming_buffer_find_by_position(buffer, start)
    between_start = (start - Myhtml::Lib.incoming_buffer_offset(buf))
    between_data = Myhtml::Lib.incoming_buffer_data(buf)
    Slice.new(between_data + between_start, size)
  end

  @[AlwaysInline]
  private def pos_to_slice(pos)
    pos_to_slice(pos.start, pos.length)
  end

  @[AlwaysInline]
  private def buffer
    Lib.tree_incoming_buffer_first(@raw_tree)
  end
end
