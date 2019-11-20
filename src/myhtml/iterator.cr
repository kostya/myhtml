require "./node"

module Myhtml::Iterator
  module Filter
    #
    # Iterator node filter
    #   returns Myhtml::Iterator::Collection
    #
    #   iterator.nodes(Myhtml::Lib::TagIdT::LXB_TAG_DIV).each { |node| ... }
    #
    def nodes(tag_id : Lib::TagIdT)
      self.select { |node| node.tag_id == tag_id }
    end

    #
    # Iterator node filter
    #   returns Myhtml::Iterator::Collection
    #
    #   iterator.nodes(:div).each { |node| ... }
    #
    def nodes(tag_sym : Symbol)
      nodes(Utils::TagConverter.sym_to_id(tag_sym))
    end

    #
    # Iterator node filter
    #   returns Myhtml::Iterator::Collection
    #
    #   iterator.nodes("div").each { |node| ... }
    #
    def nodes(tag_str : String)
      nodes(Utils::TagConverter.string_to_id(tag_str))
    end
  end
end

require "./iterator/*"
