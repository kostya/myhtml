class Myhtml::Parser
  # :nodoc:
  @doc : Lib::DocT

  #
  # Parse html from string
  # example: myhtml = Myhtml::Parser.new("<html>...</html>", encoding: Myhtml::Lib::MyEncodingList::MyENCODING_WINDOWS_1251)
  #
  # Options:
  #   **encoding** - set encoding of html (see list of encodings in Myhtml::Lib::MyEncodingList), by default it parsed as UTF-8
  #   **detect_encoding_from_meta** - try to find encoding from meta tag in the html (<meta charset=...>)
  #   **detect_encoding** - detect encoding by slow trigrams algorithm
  #   **tree_options** - additional myhtml options for parsing (see Myhtml::Lib::MyhtmlTreeParseFlags)
  #

  getter encoding : String? = nil

  def self.new(page : String)
    self.new.parse(page)
  end

  #
  # Parse html from IO
  # example: myhtml = Myhtml::Parser.new(io, encoding: Myhtml::Lib::MyEncodingList::MyENCODING_WINDOWS_1251)
  #
  # Options:
  #   **encoding** - set encoding of html (see list of encodings in Myhtml::Lib::MyEncodingList), by default it parsed as UTF-8
  #   **tree_options** - additional myhtml options for parsing (see Myhtml::Lib::MyhtmlTreeParseFlags)
  #

  def self.new(io : IO)
    self.new.parse_stream(io)
  end

  # #
  # # Top level node filter (select all nodes in tree with tag_sym)
  # #   returns Myhtml::Iterator::Collection
  # #   equal with myhtml.root!.scope.nodes(...)
  # #
  # #   myhtml.nodes(:div).each { |node| ... }
  # #
  # delegate :nodes, to: tree

  #
  # Css selectors, see Node#css
  #
  delegate :css, to: document!

  #
  # Convert html tree to html string, see Node#to_html
  #
  delegate :to_html, to: document!
  delegate :to_pretty_html, to: document!

  def root
    Node.from_raw(self, Lib.document_element(@doc))
  end

  def document
    Node.new(self, @doc.as(Void*).as(Lib::DomElementT))
  end

  def html
    root
  end

  def head
    Node.from_raw(self, Lib.tree_get_node_head(@doc))
  end

  def body
    Node.from_raw(self, Lib.tree_get_node_body(@doc))
  end

  {% for name in %w(head body html root document) %}
    def {{ name.id }}!
      if val = {{ name.id }}
        val
      else
        raise EmptyNodeError.new("expected `{{name.id}}` to present on myhtml document")
      end
    end
  {% end %}

  # :nodoc:
  protected def initialize
    @doc = Lib.document_create
    raise LibError.new("Failed to create HTML Document") if @doc.null?
    @finalized = false
  end

  def free
    finalize
  end

  def finalize
    unless @finalized
      @finalized = true
      Lib.document_destroy(@doc)
    end
  end

  # :nodoc:
  protected def parse(string)
    pointer = string.to_unsafe
    bytesize = string.bytesize

    status = Lib.document_parse(@doc, pointer, bytesize)

    if status != Lib::StatusT::LXB_STATUS_OK
      free
      raise LibError.new("parse error #{status}")
    end

    self
  end

  # :nodoc:
  BUFFER_SIZE = 8192

  # :nodoc:
  protected def parse_stream(io : IO)
    parse_stream_start

    buffer = Bytes.new(BUFFER_SIZE)

    loop do
      read_size = io.read(buffer)
      break if read_size == 0
      parse_stream_load_slice(Slice.new(buffer.to_unsafe, read_size))
    end

    parse_stream_finish

    self
  end

  private def parse_stream_start
    status = Lib.document_parse_chunk_begin(@doc)
    if status != Lib::StatusT::LXB_STATUS_OK
      free
      raise LibError.new("Failed to parse chunk begin: #{status}")
    end
  end

  private def parse_stream_load_slice(slice)
    res = Lib.document_parse_chunk(@doc, slice.to_unsafe, slice.size)
    if res != Lib::StatusT::LXB_STATUS_OK
      free
      raise LibError.new("Failed to parse chunk: #{res}")
    end
  end

  private def parse_stream_finish
    res = Lib.document_parse_chunk_end(@doc)
    if res != Lib::StatusT::LXB_STATUS_OK
      free
      raise LibError.new("Failed to parse chunk end: #{res}")
    end
  end

  protected def parse_stream_with_ec(ec : EncodingConverter, io : IO)
    parse_stream_start
    ec.convert(io) { |slice| parse_stream_load_slice(slice) }
    parse_stream_finish

    self
  end

  #
  # Create a new node
  #
  # **Note**: this does not add the node to any document or tree. It only
  # creates the object that can then be appended or inserted. See
  # `Node#append_child`, `Node#insert_after`, and `Node#insert_before`
  #
  # ```crystal
  # doc = Myhtml::Parser.new ""
  # div = doc.create_node(:div)
  # a = doc.create_node(:a)
  #
  # div.to_html # <div></div>
  # a.to_html   # <a></a>
  # ```
  #
  def create_node(tag_id : Myhtml::Lib::TagIdT)
    create_node(Myhtml::Utils::TagConverter.id_to_sym(tag_id))
  end

  def create_node(tag_sym : Symbol)
    create_node(tag_sym.to_s)
  end

  def create_node(tag_name : String)
    element = Lib.create_element(@doc, tag_name.to_unsafe, tag_name.bytesize, nil)
    Node.from_raw(self, element) || raise EmptyNodeError.new("unable to create node '#{tag_name}'")
  end

  def create_text_node(text : String)
    Node.from_raw(self, Lib.create_text_element(@doc, text.to_unsafe, text.bytesize)) || raise EmptyNodeError.new("unable to create text node")
  end

  #
  # Top level node filter (select all nodes in tree with tag_id)
  #   returns Myhtml::Iterator::Collection
  #   equal with myhtml.root!.scope.nodes(...)
  #
  #   myhtml.nodes(Myhtml::Lib::TagIdT::LXB_TAG_DIV).each { |node| ... }
  #
  def nodes(tag_id : Myhtml::Lib::TagIdT)
    # TODO: optimize?
    root!.scope.nodes(tag_id)
  end

  #
  # Top level node filter (select all nodes in tree with tag_sym)
  #   returns Myhtml::Iterator::Collection
  #   equal with myhtml.root!.scope.nodes(...)
  #
  #   myhtml.nodes(:div).each { |node| ... }
  #
  def nodes(tag_sym : Symbol)
    # TODO: optimize?
    root!.scope.nodes(tag_sym)
  end

  #
  # Top level node filter (select all nodes in tree with tag_sym)
  #   returns Myhtml::Iterator::Collection
  #   equal with myhtml.root!.scope.nodes(...)
  #
  #   myhtml.nodes("div").each { |node| ... }
  #
  def nodes(tag_str : String)
    # TODO: optimize?
    root!.scope.nodes(tag_str)
  end
end
