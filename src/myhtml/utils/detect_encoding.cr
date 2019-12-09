module Myhtml::Utils::DetectEncoding
  record BomEncoding, encoding : LibEncoding::EncodingT, shift : UInt32 do
    def shifted(slice)
      Slice.new(slice.to_unsafe + shift, slice.bytesize - shift)
    end
  end

  def self.detect_bom(slice : Slice) : BomEncoding?
    bytesize = slice.bytesize
    pointer = slice.to_unsafe

    if bytesize > 2
      if pointer[0] == 0xEF && pointer[1] == 0xBB && pointer[2] == 0xBF
        return BomEncoding.new(LibEncoding::EncodingT::LXB_ENCODING_UTF_8, 3)
      end
    end

    if bytesize > 1
      if pointer[0] == 0xFE && pointer[1] == 0xFF
        return BomEncoding.new(LibEncoding::EncodingT::LXB_ENCODING_UTF_16BE, 2)
      end

      if pointer[0] == 0xFF && pointer[1] == 0xFE
        return BomEncoding.new(LibEncoding::EncodingT::LXB_ENCODING_UTF_16LE, 2)
      end
    end
  end

  # find_in_header_value("text/html; charset=Windows-1251") => "Windows-1251"
  def self.find_in_header_value(slice : Slice) : String?
    res = Lib.html_encoding_content(slice.to_unsafe, slice.to_unsafe + slice.bytesize, out res_end)
    unless res.null?
      String.new(res, res_end - res)
    end
  end

  META_CHECK_LIMIT_BYTES = 8 * 1024

  def self.find_encodings_in_meta(slice : Slice) : Array(String)
    res = [] of String

    find_encodings_in_meta_raw(slice) do |enc_slice|
      res << String.new(enc_slice)
    end

    res
  end

  def self.find_encodings_in_meta_raw(slice : Slice)
    size = slice.bytesize
    size = {META_CHECK_LIMIT_BYTES, size}.min

    em = Lib.html_encoding_create
    raise LibError.new("Failed to init html create") if em.null?

    status = Lib.html_encoding_init(em)
    raise LibError.new("Failed to init html encoding") if status != Myhtml::Lib::StatusT::LXB_STATUS_OK

    status = Lib.html_encoding_determine(em, slice.to_unsafe, slice.to_unsafe + size)
    raise LibError.new("Failed to determine encoding") if status != Lib::StatusT::LXB_STATUS_OK

    len = Lib.html_encoding_meta_length(em)
    len.times do |i|
      entry = Lib.html_encoding_meta_entry(em, i)
      yield(Slice.new(entry.value.name, entry.value._end - entry.value.name))
    end

    len
  ensure
    Lib.html_encoding_destroy(em, false) if em
  end

  ADDITIONAL_ENCODING_ALIASES_LIST = begin
    h = {} of String => LibEncoding::EncodingT

    {% for name in %w{windows win cp windows-cp windos window} %}
      {% for suffix in ["_", "-", " ", "=", ""] %}
        {% for i in [1250, 1251, 1252, 1254, 1255, 1256, 1257, 1258] %}
          h["{{name.id}}{{suffix.id}}{{i}}"] = Myhtml::LibEncoding::EncodingT::LXB_ENCODING_WINDOWS_{{ i }}
        {% end %}
      {% end %}
    {% end %}

    h["unicode"] = Myhtml::LibEncoding::EncodingT::LXB_ENCODING_UTF_8
    h["utf"] = Myhtml::LibEncoding::EncodingT::LXB_ENCODING_UTF_8
    h["uft-8"] = Myhtml::LibEncoding::EncodingT::LXB_ENCODING_UTF_8
    h["uft8"] = Myhtml::LibEncoding::EncodingT::LXB_ENCODING_UTF_8
    h["ansi"] = Myhtml::LibEncoding::EncodingT::LXB_ENCODING_WINDOWS_1252
    h["koi8u"] = Myhtml::LibEncoding::EncodingT::LXB_ENCODING_KOI8_U
    h["koi8r"] = Myhtml::LibEncoding::EncodingT::LXB_ENCODING_KOI8_R
    h["cp-866"] = Myhtml::LibEncoding::EncodingT::LXB_ENCODING_IBM866
    h["ibm-866"] = Myhtml::LibEncoding::EncodingT::LXB_ENCODING_IBM866
    h["dos-866"] = Myhtml::LibEncoding::EncodingT::LXB_ENCODING_IBM866
    h["dos866"] = Myhtml::LibEncoding::EncodingT::LXB_ENCODING_IBM866
    h["maccyrillic"] = Myhtml::LibEncoding::EncodingT::LXB_ENCODING_X_MAC_CYRILLIC

    h["iso-88591"] = Myhtml::LibEncoding::EncodingT::LXB_ENCODING_WINDOWS_1252
    {% for i in (2..8) %}
      {% for suffix in ["_", "-", " ", "=", ""] %}
        {% for suffix2 in ["_", "-", ""] %}
          h["iso{{suffix.id}}8859{{suffix2.id}}{{i}}"] = Myhtml::LibEncoding::EncodingT::LXB_ENCODING_ISO_8859_{{i}}
          {% end %}
      {% end %}
    {% end %}

    h.rehash
    h
  end

  def self.assoc_encoding(name : String) : LibEncoding::EncodingT?
    data = LibEncoding.data_by_pre_name(name, name.bytesize)
    unless data.null?
      LibEncoding.data_encoding(data)
    end
  end

  def self.assoc_encoding_with_additionals(name : String) : LibEncoding::EncodingT?
    res = assoc_encoding(name)
    return res if res

    # TODO: optimize
    old_bytesize = name.bytesize
    name = name.downcase
    i1 = name.index(/[0-9a-z-_=]/) || 0
    i2 = name.index(/[^0-9a-z-_=]/, i1 || 0) || name.bytesize
    s2 = name[i1...i2]
    name = s2

    if name.bytesize != old_bytesize
      res = assoc_encoding(name)
      return res if res
    end

    ADDITIONAL_ENCODING_ALIASES_LIST[name]?
  end

  # Helper method:
  # To detect encoding from bom, header content-type, and meta tag
  #   and convert html page
  # for usage see: detect_encoding_spec.cr
  def self.html_detect_encoding_and_convert(content : String,
                                            content_type : String? = nil,
                                            default : String | LibEncoding::EncodingT | Nil = nil,
                                            from : String | LibEncoding::EncodingT | Nil = nil,
                                            to : String | LibEncoding::EncodingT = Myhtml::LibEncoding::EncodingT::LXB_ENCODING_UTF_8,
                                            replace : String? = "")
    slice = content.to_slice
    enc = nil
    enc_type = nil
    unfinded_encodings = [] of String

    if bom = Myhtml::Utils::DetectEncoding.detect_bom(slice)
      slice = Slice.new(slice.to_unsafe + bom.shift, slice.bytesize - bom.shift)
      enc = bom.encoding
      enc_type = :bom
    end

    if from
      if from.is_a?(String)
        if enc = Myhtml::Utils::DetectEncoding.assoc_encoding_with_additionals(from)
          enc_type = :from
        else
          unfinded_encodings << from
        end
      else
        enc_type = :from
        enc = from
      end
    end

    unless enc
      if content_type && (_enc = Myhtml::Utils::DetectEncoding.find_in_header_value(content_type.to_slice))
        if enc = Myhtml::Utils::DetectEncoding.assoc_encoding_with_additionals(_enc)
          enc_type = :header
        else
          unfinded_encodings << _enc
        end
      end
    end

    unless enc
      Myhtml::Utils::DetectEncoding.find_encodings_in_meta(slice).each do |_enc|
        if enc = Myhtml::Utils::DetectEncoding.assoc_encoding_with_additionals(_enc)
          enc_type = :meta
          break
        else
          unfinded_encodings << _enc
        end
      end
    end

    unless enc
      if default
        if default.is_a?(String)
          if enc = Myhtml::Utils::DetectEncoding.assoc_encoding_with_additionals(default)
            enc_type = :default
          else
            unfinded_encodings << default
          end
        else
          enc_type = :default
          enc = default
        end
      end
    end

    if to.is_a?(String)
      if _enc = Myhtml::Utils::DetectEncoding.assoc_encoding_with_additionals(to)
        to = _enc
      else
        raise ArgumentError.new("Unknown `to` encoding: #{to}")
      end
    end

    ec = Myhtml::EncodingConverter.new(enc || to, to, replace_str: replace)
    {enc, enc_type, ec.convert(slice), unfinded_encodings}
  end
end
