module Myhtml::Utils::HtmlEntities
  def self.decode(str : String)
    return str if str.empty?
    # TODO: optimize hard, this is really slow
    Parser.new("<body>#{str}</body>").body!.child!.tag_text
  end
end
