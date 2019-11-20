struct Myhtml::Node
  {% for name in %w(child next parent prev last_child) %}
    @[AlwaysInline]
    def {{name.id}}
      Node.from_raw(@parser, Lib.element_get_{{name.id}}(@element))
    end
  {% end %}

  {% for name in %w(child next parent prev last_child lastest_child left right next_parent flat_right) %}
    def {{name.id}}!
      if val = self.{{ name.id }}
        val
      else
        raise EmptyNodeError.new("'{{name.id}}' called from #{self.inspect}")
      end
    end
  {% end %}

  def lastest_child
    result_node = self
    while current_node = result_node.last_child
      result_node = current_node
    end
    result_node
  end

  #
  # Left node from current
  #   left means outputed in html before this
  #
  def left
    prev.try(&.lastest_child) || parent
  end

  protected def next_parent
    current_node = self
    while current_node = current_node.parent
      nxt = current_node.next
      return nxt if nxt
    end
  end

  #
  # Right node from current
  #   right means outputed in html after this
  #
  def right
    child || self.next || next_parent
  end

  #
  # Right neighbour node from current
  #   different from `right` method by not down to children nodes
  #
  def flat_right
    self.next || next_parent
  end
end
