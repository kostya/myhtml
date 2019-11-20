module Myhtml::Utils::TagConverter
  def self.sym_to_id(sym : Symbol)
    {% begin %}
    case sym
    {% for name in Lib::TagIdT.constants %}
      when :{{ name.gsub(/LXB_TAG_/, "").downcase.id }}
        Lib::TagIdT::{{ name.id }}
    {% end %}
    else
      raise ArgumentError.new("Unknown tag #{sym.inspect}")
    end
    {% end %}
  end

  def self.id_to_sym(tag_id : Lib::TagIdT)
    {% begin %}
    case tag_id
    {% for name in Lib::TagIdT.constants %}
      when Lib::TagIdT::{{ name.id }}
        :{{ name.gsub(/LXB_TAG_/, "").downcase.id }}
    {% end %}
    else
      :unknown
    end
    {% end %}
  end

  STRING_TO_SYM_MAP = begin
    h = Hash(String, Symbol).new
    {% for name in Lib::TagIdT.constants.map(&.gsub(/LXB_TAG_/, "").downcase) %}
      h["{{ name.id }}"] = :{{ name.id }}
    {% end %}
    h.rehash
    h
  end

  STRING_TO_ID_MAP = begin
    h = Hash(String, Lib::TagIdT).new
    {% for name in Lib::TagIdT.constants %}
      h["{{ name.gsub(/LXB_TAG_/, "").downcase.id }}"] = Lib::TagIdT::{{ name.id }}
    {% end %}
    h.rehash
    h
  end

  def self.string_to_sym(str : String)
    STRING_TO_SYM_MAP.fetch(str) { raise ArgumentError.new("Unknown tag #{str.inspect}") }
  end

  def self.string_to_id(str : String)
    STRING_TO_ID_MAP.fetch(str) { raise ArgumentError.new("Unknown tag #{str.inspect}") }
  end
end
