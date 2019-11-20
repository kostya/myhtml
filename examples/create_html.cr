# Example: create html

require "../src/myhtml"

doc = Myhtml::Parser.new ""
body = doc.body!

div = doc.create_node(:div)
div["class"] = "red"
body.append_child(div)

a = doc.create_node(:a)
a.inner_text = "O_o"
a["href"] = "/#"

div.append_child(a)

puts doc.to_pretty_html

# Output:
# <html>
#   <head></head>
#   <body>
#     <div class="red">
#       <a href="/#">
#         O_o
#       </a>
#     </div>
#   </body>
# </html>
