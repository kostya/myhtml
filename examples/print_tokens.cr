# Example: print html tokens using sax parser

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
  def on_token(token)
    p token
  end
end

doc = Doc.new
parser = Myhtml::SAX.new(doc)
parser.parse(str)

# Output:
# Myhtml::SAX::Token(body)
# Myhtml::SAX::Token(a, {"href" => "/link1"})
# Myhtml::SAX::Token(-text, "Link1")
# Myhtml::SAX::Token(/a)
# Myhtml::SAX::Token(a, {"class" => "red", "href" => "/link2"})
# Myhtml::SAX::Token(-text, "Link2")
# Myhtml::SAX::Token(/a)
# Myhtml::SAX::Token(/body)
# Myhtml::SAX::Token(-end-of-file)
