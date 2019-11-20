struct Myhtml::Iterator::Parents
  include ::Iterator(Node)
  include Iterator::Filter

  @start_node : Node
  @undef_node : Node
  @current_node : Node? = nil

  def initialize(@start_node)
    @undef_node = @start_node.parser.document!
    rewind
  end

  def next
    cn = @current_node = @current_node.not_nil!.parent
    case cn
    when nil, @undef_node
      stop
    else
      cn
    end
  end

  def rewind
    @current_node = @start_node
  end
end
