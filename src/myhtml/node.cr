struct Myhtml::Node
  # :nodoc:
  getter parser : Parser

  # :nodoc:
  getter element : Lib::DomElementT

  # :nodoc:
  @attributes : Hash(String, String)?

  def self.from_raw(parser, element)
    Node.new(parser, element) unless element.null?
  end

  def initialize(@parser, @element)
  end

  #
  # Tag ID
  #   node.tag_id => Myhtml::Lib::TagIdT::LXB_TAG_DIV
  #
  @[AlwaysInline]
  def tag_id : Myhtml::Lib::TagIdT
    Lib.element_get_tag_id(@element)
  end

  #
  # Tag Symbol
  #   node.tag_sym => :div
  #
  @[AlwaysInline]
  def tag_sym : Symbol
    Utils::TagConverter.id_to_sym(tag_id)
  end

  #
  # Tag Name
  #   node.tag_name => "div"
  #
  def tag_name : String
    String.new(tag_name_slice)
  end

  # :nodoc:
  @[AlwaysInline]
  def tag_name_slice
    # TODO: optimize?
    buffer = Lib.element_qualified_name(@element, out length)
    Slice.new(buffer, length)
  end

  #
  # Tag Text
  #   Direct text content of node
  #   present only on LXB_TAG__TEXT, LXB_TAG_STYLE, LXB_TAG__EM_COMMENT nodes (node.textable?)
  #   for other nodes, you should call `inner_text` method
  #
  def tag_text
    String.new(tag_text_slice)
  end

  # :nodoc:
  @[AlwaysInline]
  def tag_text_slice
    buffer = Lib.element_text_content(@element, out length)
    Slice.new(buffer, length)
  end

  # :nodoc:
  def tag_text_set(text : String, encoding = nil)
    raise ArgumentError.new("#{self.inspect} not allowed to set text") unless textable?
    # TODO: encoding?

    status = Lib.element_text_content_set(@element, text, text.bytesize)
    text
  end

  # #
  # # Node Storage
  # #   set Void* data related to this node
  # #
  # def data=(d : Void*)
  #   # Lib.node_set_data(@raw_node, d)
  # end

  # #
  # # Node Storage
  # #   get stored Void* data
  # #
  # def data
  #   # Lib.node_get_data(@raw_node)
  # end

  #
  # Node Inner Text
  #   Joined text of children nodes
  #     **deep** - option, means visit children nodes or not (by default true).
  #     **join_with** - Char or String which inserted between text parts
  #
  # Example:
  # ```
  # parser = Myhtml::Parser.new("<html><body><div>Haha <!-->WHAT?-->11</div></body></html>")
  # node = parser.nodes(:div).first
  # node.inner_text                 # => `Haha 11`
  # node.inner_text(deep: false)    # => `Haha `
  # node.inner_text(join_with: "/") # => `Haha /11`
  # ```

  def inner_text(join_with : String | Char | Nil = nil, deep = true)
    String.build { |io| inner_text(io, join_with: join_with, deep: deep) }
  end

  # :nodoc:
  def inner_text(io : IO, join_with : String | Char | Nil = nil, deep = true)
    if (join_with == nil) || (join_with == "")
      each_inner_text(deep: deep) { |slice| io.write slice }
    else
      i = 0
      each_inner_text(deep: deep) do |slice|
        io << join_with if i != 0
        io.write Utils::Strip.strip_slice(slice)
        i += 1
      end
    end
  end

  # :nodoc:
  protected def each_inner_text(deep = true)
    each_inner_text_for_scope(deep ? scope : children) { |slice| yield slice }
  end

  # :nodoc:
  protected def each_inner_text_for_scope(scope)
    scope.nodes(Lib::TagIdT::LXB_TAG__TEXT).each { |node| yield node.tag_text_slice }
  end

  #
  # Node Inspect
  #   puts node.inspect # => Myhtml::Node(:div, {"class" => "aaa"})
  #
  def inspect(io : IO)
    io << "Myhtml::Node(:"
    io << tag_sym

    if textable?
      io << ", "
      Utils::Strip.string_slice_to_io_limited(tag_text_slice, io)
    else
      _attributes = @attributes

      if _attributes || any_attribute?
        io << ", {"
        c = 0
        if _attributes
          _attributes.each do |key, value|
            io << ", " unless c == 0
            Utils::Strip.string_slice_to_io_limited(key.to_slice, io)
            io << " => "
            Utils::Strip.string_slice_to_io_limited(value.to_slice, io)
            c += 1
          end
        else
          each_attribute do |key_slice, value_slice|
            io << ", " unless c == 0
            Utils::Strip.string_slice_to_io_limited(key_slice, io)
            io << " => "
            Utils::Strip.string_slice_to_io_limited(value_slice, io)
            c += 1
          end
        end
        io << '}'
      end
    end

    io << ')'
  end
end

require "./node/*"
