require "./spec_helper"

class CounterA < Myhtml::Tokenizer::State
  @text : String?
  @pc_text : String?
  @attrs = Hash(String, String).new
  @attrs2 = Hash(String, String).new
  @c = 0
  @tag_name : String?
  @insp : String?

  def on_token(token)
    if token.tag_sym == :a && !token.closed?
      @c += 1

      @tag_name = token.tag_name

      token.each_attribute do |key, value|
        @attrs[key.to_s] = value
      end

      @insp = token.inspect

      token.each_processed_attribute do |key, value|
        @attrs2[key] = value
      end
    elsif token.tag_sym == :_text && @c > 0
      @text = token.tag_text
      @pc_text = token.processed_tag_text
    end
  end
end

class Inspecter < Myhtml::Tokenizer::State
  getter res

  def initialize
    @res = [] of String
  end

  def on_token(token)
    @res << token.inspect
  end
end

CONT1 = <<-HTML
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

INSPECT_TOKENS = ["Myhtml::Tokenizer::Token(!doctype, {\"html\" => \"\"})",
                  "Myhtml::Tokenizer::Token(html)",
                  "Myhtml::Tokenizer::Token(head)",
                  "Myhtml::Tokenizer::Token(title)",
                  "Myhtml::Tokenizer::Token(#text, \"title\")", # TODO: change to _text?
                  "Myhtml::Tokenizer::Token(/title)",
                  "Myhtml::Tokenizer::Token(/head)",
                  "Myhtml::Tokenizer::Token(body)",
                  "Myhtml::Tokenizer::Token(script)",
                  "Myhtml::Tokenizer::Token(#text, \"\n        console.log(\"js\");\n  ...\")",
                  "Myhtml::Tokenizer::Token(/script)",
                  "Myhtml::Tokenizer::Token(div, {\"class\" => \"red\"})",
                  "Myhtml::Tokenizer::Token(!--, \"comment\")", # TODO: better tag name?
                  "Myhtml::Tokenizer::Token(br/)",
                  "Myhtml::Tokenizer::Token(a, {\"href\" => \"/href\"})", # TODO: downcase href?
                  "Myhtml::Tokenizer::Token(#text, \"link &amp; lnk\")",
                  "Myhtml::Tokenizer::Token(/a)",
                  "Myhtml::Tokenizer::Token(style, \"style\")",
                  "Myhtml::Tokenizer::Token(#text, \"\n" + "          css. red\n" + "        \")",
                  "Myhtml::Tokenizer::Token(/style, \"style\")",
                  "Myhtml::Tokenizer::Token(/div)",
                  "Myhtml::Tokenizer::Token(/body)",
                  "Myhtml::Tokenizer::Token(/html)",
                  "Myhtml::Tokenizer::Token(#end-of-file)"]

def parse_doc
  Myhtml::Tokenizer::Collection.new.parse(CONT1)
end

def a_counter(str)
  CounterA.new.parse(str)
end

describe Myhtml::Tokenizer do
  context "Basic usage" do
    it "count" do
      counter = a_counter("<div><span>test</span><a href=bla>bla</a><br/></div>")
      counter.@c.should eq 1
    end

    it "find correct tag_name" do
      counter = a_counter("<div><span>test</span><A href=bla>bla &amp; ho</a><br/></div>")
      counter.@tag_name.should eq "a"
    end

    it "find correct text" do
      counter = a_counter("<div><span>test</span><a href=bla>bla &amp; ho</a><br/></div>")
      counter.@text.should eq "bla &amp; ho"
    end

    it "find correct processed text" do
      counter = a_counter("<div><span>test</span><a href=bla>bla &amp; ho</a><br/></div>")
      counter.@pc_text.should eq "bla & ho"
    end

    it "use global tags lxb_heap, but not a problem to call many times" do
      1000.times do
        counter = a_counter("<div><span>test</span><a href=bla>bla</a><br/></div>")
        counter.@c.should eq 1
        counter.free
      end
    end

    it "find correct raw attributes" do
      counter = a_counter("<div><span>test</span><a href=bla CLASS='ho&#81' what ho=>bla &amp; ho</a><br/></div>")
      counter.@attrs.should eq({"href" => "bla", "class" => "ho&#81", "what" => "", "ho" => ""})
    end

    it "find correct processed attributes" do
      counter = a_counter("<div><span>test</span><a href=bla CLASS='ho&#81' what ho=>bla &amp; ho</a><br/></div>")
      counter.@attrs2.should eq({"href" => "bla", "class" => "hoQ", "what" => "", "ho" => ""})
    end

    it "inspect" do
      counter = a_counter("<div><span>test</span><a href=bla CLASS='ho&#81' what ho=>bla &amp; ho</a><br/></div>")
      counter.@insp.should eq "Myhtml::Tokenizer::Token(a, {\"href\" => \"bla\", \"class\" => \"ho&#81\", \"what\" => \"\", \"ho\" => \"\"})"
    end
  end

  context "inspecter" do
    it "work for Tokenizer" do
      counter = Inspecter.new.parse(CONT1)
      counter.res.size.should eq 39
    end

    it "work for Tokenizer with whitespace filter" do
      counter = Inspecter.new.parse(CONT1, true)
      counter.res.size.should eq 24
      counter.res.should eq INSPECT_TOKENS
    end
  end

  context "Collection" do
    it "create" do
      doc = parse_doc
      doc.size.should eq 24
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
      t.scope.map(&.token.inspect).to_a.should eq ["Myhtml::Tokenizer::Token(#text, \"link &amp; lnk\")"]

      t.scope.text_nodes.map(&.tag_text).join.should eq "link &amp; lnk"
    end

    it "way to get last node from scope collection" do
      doc = parse_doc
      t = doc.root.right.nodes(:a).first
      scope = t.scope

      scope.text_nodes.to_a.size.should eq 1
      scope.current_node.token.inspect.should eq "Myhtml::Tokenizer::Token(/a)"
    end

    context "integration specs" do
      it "iterators inside each other" do
        doc = Myhtml::Tokenizer::Collection.new.parse("<body> <br/> a <a href='/1'>b</a> c <br/> d <a href='/2'>e</a> f <br/> </body>")

        links = [] of String

        doc.root.right.nodes(:a).each do |t|
          href = t.attribute_by("href")
          t.each_processed_attribute { |k, v| v }

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
