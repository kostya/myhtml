# Example: parse html into array of tokens with class TokensCollection,
#   and extract links from this with iterators.

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

doc = Myhtml::SAX::TokensCollection.new
parser = Myhtml::SAX.new(doc)
parser.parse(str)

doc.root.right.nodes(:a).each do |token|
  href = token.attribute_by("href")
  inner_text = token.scope.text_nodes.map(&.tag_text).join
  puts "#{inner_text}:#{href}"
end

# Output:
# Link1:/link1
# Link2:/link2
