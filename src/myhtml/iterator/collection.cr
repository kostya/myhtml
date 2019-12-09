class Myhtml::Iterator::Collection
  include ::Iterator(Node)
  include Iterator::Filter

  @id : LibC::SizeT
  @parser : Parser
  @length : LibC::SizeT
  @col : Lib::CollectionT

  def initialize(@parser, @col)
    @id = LibC::SizeT.new(0)
    @length = Lib.collection_length(@col)
    @finalized = false
  end

  def next
    if @id < @length
      node = node_by_id(@id)
      @id += 1
      node
    else
      stop
    end
  end

  @[AlwaysInline]
  private def node_by_id(i)
    node = Lib.collection_element(@col, i)
    Node.new(@parser, node) # node not null here, because i always in bounds
  end

  def size
    @length
  end

  def finalize
    free
  end

  def free
    unless @finalized
      @finalized = true
      Lib.collection_destroy(@col, true)
    end
  end

  def rewind
    @id = LibC::SizeT.new(0)
  end

  def inspect(io)
    io << "#<Myhtml::Iterator::Collection:0x"
    object_id.to_s(16, io)
    io << ": elements: "

    io << '['

    count = {2, @length}.min
    count.times do |i|
      node_by_id(i).inspect(io)
      io << ", " unless i == count - 1
    end

    io << ", ...(#{@length - 2} more)" if @length > 2
    io << ']'

    io << '>'
  end
end
