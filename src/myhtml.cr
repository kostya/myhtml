module Myhtml
  VERSION = "1.5.9"

  def self.lib_version
    v = Lib.version
    {v.major, v.minor, v.patch}
  end

  def self.version
    "Myhtml v#{VERSION} (libmyhtml v#{lib_version.join('.')})"
  end

  #
  # Decode html entities
  #   Myhtml.decode_html_entities("&#61 &amp; &Auml") # => "= & Ä"
  #
  def self.decode_html_entities(str : String)
    Utils::HtmlEntities.decode(str)
  end

  def self.decode_html_entities(bytes : Bytes)
    Utils::HtmlEntities.decode(bytes)
  end
end

require "./myhtml/lib"
require "./myhtml/*"
