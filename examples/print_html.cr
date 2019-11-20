# Example: PRINT HTML
#   * close not closed tags
#   * replace entities
#   * downcase attributes & tags names
#   * remove comments and whitespaces
#   * formatting

require "../src/myhtml"

str = if filename = ARGV[0]?
        File.read(filename, "UTF-8", invalid: :skip)
      else
        <<-HTML
          <!doctype html>
          <html>
            <div>
            <span CLASS=bla>⬣ ⬤ ⬥ ⬦</div></span>
            <--->&<!--bla-->
            &#61; &amp;
            asdf</BODY>
          </html>
        HTML
      end

formatting = (ARGV[1]? != "0")
remove_whitespaces = (ARGV[2]? != "0")
remove_comments = (ARGV[3]? != "0")

myhtml = Myhtml::Parser.new(str)

if remove_comments
  myhtml.nodes(:_em_comment).each(&.remove!)
end

if formatting
  puts myhtml.to_pretty_html
else
  puts myhtml.to_html
end

# Output:
# <!DOCTYPE html>
# <html>
#   <head></head>
#   <body>
#     <div>
#       <span class="bla">
#         ⬣ ⬤ ⬥ ⬦
#       </span>
#     </div>
#     <--->&
#     = &
#     asdf
#   </body>
# </html>
