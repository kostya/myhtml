# require "./spec_helper"

# describe Myhtml do
#   it "direct use CssFilter" do
#     html = "<div><p id=p1><p id=p2><p id=p3><a>link</a><p id=p4><p id=p5><p id=p6></div>"
#     selector = "div > :nth-child(2n+1):not(:has(a))"

#     parser = Myhtml::Parser.new(html)
#     finder = Myhtml::CssFilter.new(selector)
#     nodes = finder.search_from(parser.html!).to_a

#     nodes.size.should eq 2

#     n1, n2 = nodes

#     n1.tag_name.should eq "p"
#     n1.attribute_by("id").should eq "p1"

#     n2.tag_name.should eq "p"
#     n2.attribute_by("id").should eq "p5"
#   end

#   it "css for root! node" do
#     html = "<div><p id=p1><p id=p2 class=jo><p id=p3><a>link</a><span id=bla><p id=p4 class=jo><p id=p5 class=bu><p id=p6 class=jo></span></div>"

#     parser = Myhtml::Parser.new(html)
#     nodes = parser.root!.css("div > :nth-child(2n+1):not(:has(a))").to_a

#     nodes.size.should eq 2

#     n1, n2 = nodes

#     n1.tag_name.should eq "p"
#     n1.attribute_by("id").should eq "p1"

#     n2.tag_name.should eq "p"
#     n2.attribute_by("id").should eq "p5"
#   end

#   it "another rule" do
#     html = "<div><p id=p1><p id=p2 class=jo><p id=p3><a>link</a><span id=bla><p id=p4 class=jo><p id=p5 class=bu><p id=p6 class=jo></span></div>"

#     parser = Myhtml::Parser.new(html)
#     parser.root!.css(".jo").to_a.map(&.attribute_by("id")).should eq %w(p2 p4 p6)
#   end

#   it "another rule for parser itself" do
#     html = "<div><p id=p1><p id=p2 class=jo><p id=p3><a>link</a><span id=bla><p id=p4 class=jo><p id=p5 class=bu><p id=p6 class=jo></span></div>"

#     parser = Myhtml::Parser.new(html)
#     parser.css(".jo").to_a.map(&.attribute_by("id")).should eq %w(p2 p4 p6)
#   end

#   it "work for another scope node" do
#     html = "<div><p id=p1><p id=p2 class=jo><p id=p3><a>link</a><div id=bla><p id=p4 class=jo><p id=p5 class=bu><p id=p6 class=jo></div></div>"

#     parser = Myhtml::Parser.new(html)
#     parser.nodes(:div).to_a.last.css(".jo").to_a.map(&.attribute_by("id")).should eq %w(p4 p6)
#     parser.nodes(:div).to_a.first.css(".jo").to_a.map(&.attribute_by("id")).should eq %w(p2 p4 p6)
#   end

#   context "build finder" do
#     it "for parser" do
#       html = "<div><p id=p1><p id=p2 class=jo><p id=p3><a>link</a><span id=bla><p id=p4 class=jo><p id=p5 class=bu><p id=p6 class=jo></span></div>"

#       parser = Myhtml::Parser.new(html)
#       finder = Myhtml::CssFilter.new(".jo")

#       10.times do
#         parser.root!.css(finder).to_a.map(&.attribute_by("id")).should eq %w(p2 p4 p6)
#       end

#       finder.inspect.should eq "Myhtml::CssFilter(rule: `.jo`)"
#     end

#     it "for parser" do
#       html = "<div><p id=p1><p id=p2 class=jo><p id=p3><a>link</a><span id=bla><p id=p4 class=jo><p id=p5 class=bu><p id=p6 class=jo></span></div>"

#       parser = Myhtml::Parser.new(html)
#       finder = Myhtml::CssFilter.new(".jo")

#       10.times do
#         parser.css(finder).to_a.map(&.attribute_by("id")).should eq %w(p2 p4 p6)
#       end
#     end

#     it "for root node" do
#       html = "<div><p id=p1><p id=p2 class=jo><p id=p3><a>link</a><span id=bla><p id=p4 class=jo><p id=p5 class=bu><p id=p6 class=jo></span></div>"

#       parser = Myhtml::Parser.new(html)
#       finder = Myhtml::CssFilter.new(".jo")

#       10.times do
#         parser.root!.css(finder).to_a.map(&.attribute_by("id")).should eq %w(p2 p4 p6)
#       end
#     end
#   end

#   it "should not raise on empty selector" do
#     html = "<div><p id=p1><p id=p2 class=jo><p id=p3><a>link</a><span id=bla><p id=p4 class=jo><p id=p5 class=bu><p id=p6 class=jo></span></div>"

#     parser = Myhtml::Parser.new(html)
#     finder = Myhtml::CssFilter.new("")
#     parser.css(finder).to_a.size.should eq 0
#   end

#   it "integration test" do
#     html = <<-PAGE
#       <div>
#         <p id=p1>
#         <p id=p2 class=jo>
#         <p id=p3>
#           <a href="some.html" id=a1>link1</a>
#           <a href="some.png" id=a2>link2</a>
#         <div id=bla>
#           <p id=p4 class=jo>
#           <p id=p5 class=bu>
#           <p id=p6 class=jo>
#         </div>
#       </div>
#     PAGE

#     parser = Myhtml::Parser.new(html)

#     # select all p nodes which id like `*p*`
#     parser.css("p[id*=p]").map(&.attribute_by("id")).to_a.should eq ["p1", "p2", "p3", "p4", "p5", "p6"]

#     # select all nodes with class "jo"
#     parser.css("p.jo").map(&.attribute_by("id")).to_a.should eq ["p2", "p4", "p6"]
#     parser.css(".jo").map(&.attribute_by("id")).to_a.should eq ["p2", "p4", "p6"]

#     # select odd child tag inside div, which not contain a
#     parser.css("div > :nth-child(2n+1):not(:has(a))").map(&.attribute_by("id")).to_a.should eq ["p1", "p4", "p6"]

#     # all elements with class=jo inside last div tag
#     parser.css("div").to_a.last.css(".jo").map(&.attribute_by("id")).to_a.should eq ["p4", "p6"]

#     # a element with href ends like .png
#     parser.css(%q{a[href$=".png"]}).map(&.attribute_by("id")).to_a.should eq ["a2"]

#     # find all a tags inside <p id=p3>, which href contain `html`
#     parser.css(%q{p[id=p3] > a[href*="html"]}).map(&.attribute_by("id")).to_a.should eq ["a1"]

#     # find all a tags inside <p id=p3>, which href contain `html` or ends_with `.png`
#     parser.css(%q{p[id=p3] > a:matches([href *= "html"], [href $= ".png"])}).map(&.attribute_by("id")).to_a.should eq ["a1", "a2"]

#     # create finder and use it in many places
#     finder = Myhtml::CssFilter.new(".jo")
#     parser.css(finder).map(&.attribute_by("id")).to_a.should eq ["p2", "p4", "p6"]
#   end

#   it "integration test2" do
#     html = <<-PAGE
#       <html><body>
#       <table id="t1"><tbody>
#       <tr><td>Hello</td></tr>
#       </tbody></table>
#       <table id="t2"><tbody>
#       <tr><td>123</td><td>other</td></tr>
#       <tr><td>foo</td><td>columns</td></tr>
#       <tr><td>bar</td><td>are</td></tr>
#       <tr><td>xyz</td><td>ignored</td></tr>
#       </tbody></table>
#       </body></html>
#     PAGE

#     parser = Myhtml::Parser.new(html)
#     parser.css("#t2 tr td:first-child").map(&.inner_text).to_a.should eq ["123", "foo", "bar", "xyz"]
#     parser.css("#t2 tr td:first-child").map(&.to_html).to_a.should eq ["<td>123</td>", "<td>foo</td>", "<td>bar</td>", "<td>xyz</td>"]

#     res = [] of String
#     parser.css("#t2 tr").each do |node|
#       res << node.css("td:first-child").first.inner_text
#     end
#     res.join('|').should eq "123|foo|bar|xyz"
#   end

#   it "not sigfaulting on more than 1024 elements" do
#     str = "<html>" + "<div class=A>ooo</div>" * 20000 + "</html>"
#     parser = Myhtml::Parser.new(str)

#     c = 0
#     x = 0
#     parser.css("div").each do |node|
#       x += 1
#       c += 1 if node.attribute_by("class") == "A"
#     end
#     x.should eq 20000
#     c.should eq 20000
#   end

#   it "bug in css" do
#     parser = Myhtml::Parser.new(%q{<div class="asfjjjj">bla</div>})
#     parser.css("div.jjjj").to_a.size.should eq 0
#   end

#   it "css with yield" do
#     parser = Myhtml::Parser.new(%q{<div class="jjjj">bla</div>})
#     parser.css("div.jjjj") { |col| col.to_a.size }.should eq 1
#   end
# end
