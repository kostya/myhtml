class Myhtml::CssFilter
  #
  # Css filter
  #   Myhtml::CssFilter.new("div.red").search_from(myhtml.html!) # => Myhtml::Iterator::Collection
  #
  def initialize(@rule : String, encoding = nil)
    @finalized = false

    # @raw_mycss = LibMyCss.create

    # status = LibMyCss.init(@raw_mycss)
    # if status != LibMyCss::MycssStatusT::MyCSS_STATUS_OK
    #   LibMyCss.destroy(@raw_mycss, true)
    #   raise Myhtml::LibError.new("mycss init error #{status}")
    # end

    # @raw_entry = LibMyCss.entry_create
    # status = LibMyCss.entry_init(@raw_mycss, @raw_entry)
    # if status != LibMyCss::MycssStatusT::MyCSS_STATUS_OK
    #   LibMyCss.entry_destroy(@raw_entry, true)
    #   LibMyCss.destroy(@raw_mycss, true)
    #   raise Myhtml::LibError.new("mycss entry_init error #{status}")
    # end

    # @finder = LibModest.finder_create_simple
    # @selectors = LibMyCss.entry_selectors(@raw_entry)
    # @list = LibMyCss.selectors_parse(@selectors, encoding || Myhtml::Lib::MyEncodingList::MyENCODING_DEFAULT, rule, rule.bytesize, out status2)
    # if status2 != LibMyCss::MycssStatusT::MyCSS_STATUS_OK
    #   free
    #   raise Myhtml::LibError.new("finder selectors_parse #{status2}")
    # end
  end

  def search_from(scope_node : Myhtml::Node)
    # collection = Pointer(Myhtml::Lib::MyhtmlCollectionT).new(0)
    # LibModest.finder_by_selectors_list(@finder, scope_node.@raw_node, @list, pointerof(collection))
    # Iterator::Collection.new(scope_node.tree, collection)

    col = Lib.collection_make(scope_node.@parser.@doc, 1)
    if col.null?
      raise LibError.new("unable to create collection")
    end
    Iterator::Collection.new(scope_node.@parser, col)
  end

  def free
    unless @finalized
      @finalized = true
      # LibMyCss.selectors_list_destroy(@selectors, @list, true)
      # LibModest.finder_destroy(@finder, true)
      # LibMyCss.entry_destroy(@raw_entry, true)
      # LibMyCss.destroy(@raw_mycss, true)
    end
  end

  def finalize
    free
  end

  def inspect(io)
    io << "Myhtml::CssFilter(rule: `"
    io << @rule
    io << "`)"
  end
end
