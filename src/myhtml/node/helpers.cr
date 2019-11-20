struct Myhtml::Node
  # :nodoc:
  def self_closed?
    # Lib.node_is_close_self(@raw_node)
    false
  end

  # :nodoc:
  def void_element?
    Lib.node_is_void(@element)
  end

  def textable?
    case tag_id
    when Lib::TagIdT::LXB_TAG__TEXT,
         Lib::TagIdT::LXB_TAG__EM_COMMENT,
         Lib::TagIdT::LXB_TAG_STYLE
      true
    else
      false
    end
  end

  def visible?
    case tag_id
    when Lib::TagIdT::LXB_TAG_STYLE,
         Lib::TagIdT::LXB_TAG__EM_COMMENT,
         Lib::TagIdT::LXB_TAG_SCRIPT,
         Lib::TagIdT::LXB_TAG_HEAD
      false
    else
      true
    end
  end

  def object?
    case tag_id
    when Lib::TagIdT::LXB_TAG_APPLET,
         Lib::TagIdT::LXB_TAG_IFRAME,
         Lib::TagIdT::LXB_TAG_FRAME,
         Lib::TagIdT::LXB_TAG_FRAMESET,
         Lib::TagIdT::LXB_TAG_EMBED,
         Lib::TagIdT::LXB_TAG_OBJECT
      true
    else
      false
    end
  end

  {% for name in Lib::TagIdT.constants %}
    def is_tag_{{ name.gsub(/LXB_TAG_/, "").downcase.id }}?
      tag_id == Lib::TagIdT::{{ name.id }}
    end
  {% end %}

  def is_text?
    tag_id == Lib::TagIdT::LXB_TAG__TEXT
  end

  def is_comment?
    tag_id == Lib::TagIdT::LXB_TAG__EM_COMMENT
  end

  def is_tag_noindex?
    tag_id >= Lib::TagIdT::LXB_TAG__LAST_ENTRY && tag_name_slice == "noindex".to_slice
  end

  def is_tag_nofollow?
    tag_id >= Lib::TagIdT::LXB_TAG__LAST_ENTRY && tag_name_slice == "nofollow".to_slice
  end
end
