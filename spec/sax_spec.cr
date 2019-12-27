require "./spec_helper"

SAX_CONT1 = <<-HTML
  <!doctype html>
  <html>
    <head>
      <title>title</title>
    </head>
    <body>
      <script>
        console.log("js");
      </script>
      <div class=red>
        <!--comment-->
        <br/>
        <a HREF="/href">link &amp; lnk</a>
        <style>
          css. red
        </style>
      </div>
    </body>
  </html>
HTML

INSPECT_TOKENS = ["Myhtml::SAX::Token(!doctype, {\"html\" => \"\"})",
                  "Myhtml::SAX::Token(html)",
                  "Myhtml::SAX::Token(head)",
                  "Myhtml::SAX::Token(title)",
                  "Myhtml::SAX::Token(-text, \"title\")",
                  "Myhtml::SAX::Token(/title)",
                  "Myhtml::SAX::Token(/head)",
                  "Myhtml::SAX::Token(body)",
                  "Myhtml::SAX::Token(script)",
                  "Myhtml::SAX::Token(/script)",
                  "Myhtml::SAX::Token(div, {\"class\" => \"red\"})",
                  "Myhtml::SAX::Token(_comment, \"comment\")",
                  "Myhtml::SAX::Token(br/)",
                  "Myhtml::SAX::Token(a, {\"href\" => \"/href\"})",
                  "Myhtml::SAX::Token(-text, \"link &amp; lnk\")",
                  "Myhtml::SAX::Token(/a)",
                  "Myhtml::SAX::Token(style, \"style\")",
                  "Myhtml::SAX::Token(-text, \"\n" + "          css. red\n" + "        \")",
                  "Myhtml::SAX::Token(/style, \"style\")",
                  "Myhtml::SAX::Token(/div)",
                  "Myhtml::SAX::Token(/body)",
                  "Myhtml::SAX::Token(/html)",
                  "Myhtml::SAX::Token(-end-of-file)"]

class Doc1 < Myhtml::SAX::Tokenizer
  getter res

  def initialize
    @res = [] of String
  end

  def on_token(token)
    @res << token.inspect
  end
end

def parse_doc
  doc = Myhtml::SAX::TokensCollection.new
  parser = Myhtml::SAX.new(doc)
  parser.parse(SAX_CONT1)
  doc
end

describe Myhtml::SAX do
  it "work for Tokenizer" do
    doc = Doc1.new
    parser = Myhtml::SAX.new(doc, build_tree: false, skip_whitespace_token: true)
    parser.parse(SAX_CONT1)
    doc.res.should eq INSPECT_TOKENS
  end

  context "TokensCollection" do
    it "create" do
      doc = parse_doc
      doc.size.should eq 23
    end

    it "iterate with next" do
      doc = parse_doc
      node = doc.first
      res = [] of String
      while node
        res << node.token.inspect
        node = node.next
      end
      res.should eq INSPECT_TOKENS
    end

    it "iterate with prev" do
      doc = parse_doc
      node = doc.last
      res = [] of String
      while node
        res << node.token.inspect
        node = node.prev
      end
      res.should eq INSPECT_TOKENS.reverse
    end

    it "iterate with right iterator" do
      doc = parse_doc
      doc.root.right.map(&.token.inspect).to_a.should eq INSPECT_TOKENS
    end

    it "iterate with left iterator" do
      doc = parse_doc
      doc.last.left.map(&.token.inspect).to_a.should eq INSPECT_TOKENS.reverse[1..-1]
    end

    it "scope and nodes iterator" do
      doc = parse_doc
      t = doc.root.right.nodes(:a).first
      t.attribute_by("href").should eq "/href"
      t.scope.map(&.token.inspect).to_a.should eq ["Myhtml::SAX::Token(-text, \"link &amp; lnk\")"]

      t.scope.text_nodes.map(&.tag_text).join.should eq "link &amp; lnk"
    end

    it "way to get last node from scope collection" do
      doc = parse_doc
      t = doc.root.right.nodes(:a).first
      scope = t.scope

      scope.text_nodes.to_a.size.should eq 1
      scope.current_node.token.inspect.should eq "Myhtml::SAX::Token(/a)"
    end

    context "integration specs" do
      it "iterators inside each other" do
        doc = Myhtml::SAX::TokensCollection.new
        parser = Myhtml::SAX.new(doc)
        parser.parse("<body> <br/> a <a href='/1'>b</a> c <br/> d <a href='/2'>e</a> f <br/> </body>")

        links = [] of String

        doc.root.right.nodes(:a).each do |t|
          href = t.attribute_by("href")

          inner_text = t.scope.text_nodes.map(&.tag_text).join.strip
          left_text = t.left.text_nodes.first.tag_text.strip
          right_text = t.scope.to_a.last.right.text_nodes.first.tag_text.strip

          links << "#{left_text}:#{inner_text}:#{right_text}:#{href}"
        end

        links.should eq ["a:b:c:/1", "d:e:f:/2"]
      end
    end
  end
end
