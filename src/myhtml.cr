module Myhtml
  VERSION = "1.4.2"

  def self.lib_version
  end

  def self.version
    "Myhtml v#{VERSION} (liblexbor v0.4.0-12-gb6c9c73)" # git describe --tags
  end

  #
  # Decode html entities
  #   Myhtml.decode_html_entities("&#61 &amp; &Auml") # => "= & Ä"
  #
  def self.decode_html_entities(str)
    Utils::HtmlEntities.decode(str)
  end
end

require "./myhtml/lib"
require "./myhtml/*"
