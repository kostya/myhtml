module Myhtml
  class Parser
    getter :myhtml, :tree

    def initialize(options = 0, threads_count = 1, queue_size = 0)
      @myhtml = Lib.create
      res = Lib.init(@myhtml, options, threads_count, queue_size) # MyHTML_OPTIONS_DEFAULT
      
      if res != 0 # OK_STATUS
        raise Error.new("init error #{res}")
      end

      @tree = Tree.new(@myhtml)
    end

    def parse(string, encoding = 0)
      res = Lib.parse(@tree.tree, encoding, string.to_unsafe, string.size) # MyHTML_ENCODING_UTF_8
      if res == 0
        :ok
      else
        raise Error.new("parse error #{res}")
      end
    end

    def root
      Node.from_raw(self, Lib.tree_get_node_html(@tree.tree))
    end

    def finalize
      @tree.destroy
      Lib.destroy(@myhtml)
    end

    def tags_count(tag_id)
      Myhtml::Lib.tag_index_entry_count(tag_index, tag_id)
    end

    def each_tag(tag_id, &block : Node ->)
      index_node = Lib.tag_index_first(tag_index, tag_id)
      while !index_node.null?
        node = Lib.tag_index_tree_node(index_node)
        unless node.null?
          node = Node.from_raw(self, node).not_nil!
          yield node
          index_node = Lib.tag_index_next(index_node)
        else
          break
        end
      end
      self
    end

    private def tag_index
      @tag_index ||= Lib.tree_get_tag_index(@tree.tree)
    end
  end
end
