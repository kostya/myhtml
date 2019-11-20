module Myhtml::Utils::HtmlEntities
  def self.decode(str : String)
    # TODO: optimize hard, this is really slow
    Parser.new("<div>#{str}</div>").nodes(:div).first.inner_text
  end
end
