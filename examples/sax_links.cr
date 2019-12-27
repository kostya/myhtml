# Example: extract links from html with sax parser
#   this is faster and cheaper, when you not need to build full html document

require "../src/myhtml"

str = if filename = ARGV[0]?
        File.read(filename, "UTF-8", invalid: :skip)
      else
        <<-HTML
          <body>
            <a href="/link1">Link1</a>
            <a class=red HREF="/link2">Link2</a>
          </body>
        HTML
      end

class Doc < Myhtml::SAX::Tokenizer
  getter hrefs

  def initialize
    @hrefs = [] of String
  end

  def on_token(token)
    if token.tag_sym == :a && !token.closed?
      if href = token.attribute_by("href")
        @hrefs << href
      end
    end
  end
end

doc = Doc.new
parser = Myhtml::SAX.new(doc)
parser.parse(str)
p doc.hrefs

# Output:
# ["/link1", "/link2"]
