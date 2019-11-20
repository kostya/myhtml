# Example: print html tree

require "../src/myhtml"

def walk(node, level = 0)
  puts "#{" " * level * 2}#{node.inspect}"
  node.children.each { |child| walk(child, level + 1) }
end

str = if filename = ARGV[0]?
        File.read(filename, "UTF-8", invalid: :skip)
      else
        "<html><Div><span class='test'>HTML</span></div></html>"
      end

parser = Myhtml::Parser.new(str)
walk(parser.root!)

# Output:
# Myhtml::Node(:html)
#   Myhtml::Node(:head)
#   Myhtml::Node(:body)
#     Myhtml::Node(:div)
#       Myhtml::Node(:span, {"class" => "test"})
#         Myhtml::Node(:_text, "HTML")
