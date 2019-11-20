# Example: basic usage

require "../src/myhtml"

puts Myhtml.version

page = "<html><div class=aaa>bla</div></html>"
myhtml = Myhtml::Parser.new(page)

# html node
myhtml.root  # (.html) Myhtml::Node?
myhtml.root! # (.html!) Myhtml::Node

# body node
myhtml.body  # Myhtml::Node?
myhtml.body! # Myhtml::Node

# head node
myhtml.head  # Myhtml::Node?
myhtml.head! # Myhtml::Node

# iterator over all div nodes from root scope
# equal with myhtml.root!.scope.nodes(:div)
myhtml.nodes(Myhtml::Lib::TagIdT::LXB_TAG_DIV) # Iterator::Collection(Myhtml::Node)
myhtml.nodes(:div)                             # Iterator::Collection(Myhtml::Node)
myhtml.nodes("div")                            # Iterator::Collection(Myhtml::Node)

node = myhtml.nodes(:div).first # Myhtml::Node

# methods:
pp node.tag_id                # => MyHTML_TAG_DIV
pp node.tag_sym               # => :div
pp node.tag_name              # => "div"
pp node.is_tag_div?           # => true
pp node.attribute_by("class") # => "aaa"
pp node.attributes            # => {"class" => "aaa"}

pp node.to_html    # => "<div class=\"aaa\">bla</div>"
pp node.inner_text # => "bla"
pp node            # => Myhtml::Node(:div, {"class" => "aaa"})

# tree navigate methods (methods with !, returns not_nil! node):
node.child      # Myhtml::Node?, first child of node
node.next       # Myhtml::Node?, next node in the parent scope
node.parent     # Myhtml::Node?, parent node
node.prev       # Myhtml::Node?, previous node in the parent scope
node.left       # Myhtml::Node?, left node, in the html, from current
node.right      # Myhtml::Node?, right node, in the html, from current
node.flat_right # Myhtml::Node?, right node, in the html, from current, without node.children

# iterators:
node.children        # Iterator::Collection(Myhtml::Node), iterate over all direct node children
node.parents         # Iterator::Collection(Myhtml::Node), iterate over all node parents from current to root! node
node.scope           # Iterator::Collection(Myhtml::Node), iterate over all inner nodes (children and deeper)
node.right_iterator  # Iterator::Collection(Myhtml::Node), iterate from current node to right (to the end of document)
node.left_iterator   # Iterator::Collection(Myhtml::Node), iterate from current node to left (to the root! node)
node.scope.nodes(:a) # Iterator::Collection(Myhtml::Node), select :a nodes in scope of `node`

# free myhtml c object,
# not really needed to call manyally, because called auto from GC finalize, when object not used anymore
# use it only if need to free memory fast
# after free any other child object like Myhtml::Node or Iterator::Collection(Myhtml::Node) not valid anymore and can lead to segfault
myhtml.free
