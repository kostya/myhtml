require "./lib/*"

module Myhtml
  @[Link(ldflags: "#{__DIR__}/../ext/lexbor-c/build/liblexbor_static.a")]
  lib Lib
    type DocT = Void*
    type CollectionT = Void*
    type DomElementT = Void*
    type DomAttrT = Void*

    # Document
    fun document_create = lxb_html_document_create : DocT
    fun document_parse = lxb_html_document_parse(doc : DocT, html : UInt8*, len : LibC::SizeT) : StatusT
    fun document_destroy = lxb_html_document_destroy(doc : DocT)
    fun document_parse_chunk_begin = lxb_html_document_parse_chunk_begin(doc : DocT) : StatusT
    fun document_parse_chunk = lxb_html_document_parse_chunk(doc : DocT, html : UInt8*, size : LibC::SizeT) : StatusT
    fun document_parse_chunk_end = lxb_html_document_parse_chunk_end(doc : DocT) : StatusT

    # Root nodes
    fun tree_get_node_head = lxb_html_document_head_element_noi(doc : DocT) : DomElementT
    fun tree_get_node_body = lxb_html_document_body_element_noi(doc : DocT) : DomElementT
    fun document_element = lxb_dom_document_element_noi(doc : DocT) : DomElementT

    # Collections
    fun collection_make = lxb_dom_collection_make_noi(doc : DocT, start_list_size : LibC::SizeT) : CollectionT
    fun collection_element = lxb_dom_collection_element_noi(col : CollectionT, idx : LibC::SizeT) : DomElementT
    fun collection_length = lxb_dom_collection_length_noi(col : CollectionT) : LibC::SizeT
    fun collection_destroy = lxb_dom_collection_destroy(col : CollectionT, self_destroy : Bool) : CollectionT

    # Element info methods
    fun element_get_tag_id = lxb_dom_node_tag_id_noi(element : DomElementT) : Myhtml::Lib::TagIdT
    fun element_text_content = lxb_dom_node_text_content(element : DomElementT, len : LibC::SizeT*) : UInt8*
    fun element_text_content_set = lxb_dom_node_text_content_set(element : DomElementT, content : UInt8*, len : LibC::SizeT) : StatusT
    fun element_qualified_name = lxb_dom_element_qualified_name_noi(element : DomElementT, len : LibC::SizeT*) : UInt8*
    fun element_local_name = lxb_dom_element_local_name_noi(element : DomElementT, len : LibC::SizeT*) : UInt8*
    fun node_is_void = lxb_html_node_is_void_noi(element : DomElementT) : Bool

    # Navigation methods
    fun element_get_next = lxb_dom_node_next_noi(element : DomElementT) : DomElementT
    fun element_get_prev = lxb_dom_node_prev_noi(element : DomElementT) : DomElementT
    fun element_get_parent = lxb_dom_node_parent_noi(element : DomElementT) : DomElementT
    fun element_get_child = lxb_dom_node_first_child_noi(element : DomElementT) : DomElementT
    fun element_get_last_child = lxb_dom_node_last_child_noi(element : DomElementT) : DomElementT

    # Attribute methods
    fun element_first_attribute = lxb_dom_element_first_attribute_noi(element : DomElementT) : DomAttrT
    fun element_next_attribute = lxb_dom_element_next_attribute_noi(attr : DomAttrT) : DomAttrT
    fun attribute_value = lxb_dom_attr_value_noi(attr : DomAttrT, length : LibC::SizeT*) : UInt8*
    fun attribute_local_name = lxb_dom_attr_local_name_noi(attr : DomAttrT, length : LibC::SizeT*) : UInt8*
    fun attribute_qualified_name = lxb_dom_attr_qualified_name_noi(attr : DomAttrT, length : LibC::SizeT*) : UInt8*
    fun attribute_remove = lxb_dom_element_remove_attribute(element : DomElementT, name : UInt8*, len : LibC::SizeT) : StatusT
    fun element_set_attribute = lxb_dom_element_set_attribute(element : DomElementT, qualified_name : UInt8*, qn_len : LibC::SizeT, value : UInt8*, value_len : LibC::SizeT) : DomAttrT

    # Serialize
    type SerializeCbT = (UInt8*, LibC::SizeT, Void*) -> StatusT
    fun serialize_cb = lxb_html_serialize_cb(element : DomElementT, cb : SerializeCbT, ctx : Void*) : StatusT
    fun serialize_tree_cb = lxb_html_serialize_tree_cb(element : DomElementT, cb : SerializeCbT, ctx : Void*) : StatusT
    fun serialize_pretty_cb = lxb_html_serialize_pretty_cb(element : DomElementT, opt : SerializeOptT, ident : LibC::SizeT, cb : SerializeCbT, ctx : Void*) : StatusT
    fun serialize_pretty_tree_cb = lxb_html_serialize_pretty_tree_cb(element : DomElementT, opt : SerializeOptT, ident : LibC::SizeT, cb : SerializeCbT, ctx : Void*) : StatusT

    # Tree manipulation
    fun insert_child = lxb_dom_node_insert_child(to : DomElementT, element : DomElementT)
    fun insert_before = lxb_dom_node_insert_before(to : DomElementT, element : DomElementT)
    fun insert_after = lxb_dom_node_insert_after(to : DomElementT, element : DomElementT)
    fun node_remove = lxb_dom_node_remove(element : DomElementT)
    fun create_element = lxb_dom_document_create_element(doc : DocT, local_name : UInt8*, lname_len : LibC::SizeT, opt : Void*) : DomElementT
    fun create_text_element = lxb_dom_document_create_text_node(doc : DocT, data : UInt8*, len : LibC::SizeT) : DomElementT

    # Iterators
    fun simple_walk = lxb_dom_node_simple_walk(from : DomElementT, cb : Void*, ctx : Void*)
    # fun elements_by_tag_name = lxb_dom_elements_by_tag_name(root : DomElementT, col : CollectionT, qualified_name : UInt8*, len : LibC::SizeT) : StatusT

    # Tokenizer
    type TagHeapT = Void*
    type HtmlTokenizerT = Void*
    type InModeT = Void*
    type MRawT = Void*

    struct Str
      data : UInt8*
      length : LibC::SizeT
    end

    type StrT = Str*

    struct HtmlToken
      begin_ : UInt8*
      end_ : UInt8*
      in_begin : InModeT
      attr_first : HtmlTokenAttrT
      attr_last : HtmlTokenAttrT
      base_element : Void*
      tag_id : TagIdT
      type_ : HtmlTokenTypeT
    end

    type HtmlTokenT = HtmlToken*
    type HtmlTokenizerTokenF = HtmlTokenizerT, HtmlTokenT, Void* -> HtmlTokenT

    fun html_tokenizer_create = lxb_html_tokenizer_create : HtmlTokenizerT
    fun html_tokenizer_init = lxb_html_tokenizer_init(tkz : HtmlTokenizerT) : StatusT
    fun html_tokenizer_opt_set = lxb_html_tokenizer_opt_set_noi(tkz : HtmlTokenizerT, opt : HtmlTokenizerOptT)
    fun html_tokenizer_callback_token_done_set = lxb_html_tokenizer_callback_token_done_set_noi(tkx : HtmlTokenizerT, cb : HtmlTokenizerTokenF, ctx : Void*)
    fun html_tokenizer_begin = lxb_html_tokenizer_begin(tkz : HtmlTokenizerT) : StatusT
    fun html_tokenizer_chunk = lxb_html_tokenizer_chunk(tkz : HtmlTokenizerT, data : UInt8*, size : LibC::SizeT) : StatusT
    fun html_tokenizer_end = lxb_html_tokenizer_end(tkz : HtmlTokenizerT) : StatusT
    fun html_tokenizer_destroy = lxb_html_tokenizer_destroy(tkz : HtmlTokenizerT) : HtmlTokenizerT
    fun tag_heap_create = lxb_tag_heap_create : TagHeapT
    fun tag_heap_init = lxb_tag_heap_init(heap : TagHeapT, size : LibC::SizeT) : StatusT
    fun tag_heap_destroy = lxb_tag_heap_destroy(heap : TagHeapT) : TagHeapT
    fun tag_name_by_id = lxb_tag_name_by_id_noi(heap : TagHeapT, tag_id : TagIdT, len : LibC::SizeT*) : UInt8*
    fun html_tokenizer_tag_heap_set = lxb_html_tokenizer_tag_heap_set_noi(tkz : HtmlTokenizerT, heap : TagHeapT)
    fun html_tokenizer_tag_heap = lxb_html_tokenizer_tag_heap_noi(tkz : HtmlTokenizerT) : TagHeapT
    fun html_token_tag_id_from_data = lxb_html_token_tag_id_from_data(heap : TagHeapT, token : HtmlTokenT) : TagIdT
    fun html_tokenizer_status_set = lxb_html_tokenizer_status_set_noi(tkz : HtmlTokenizerT, status : StatusT)

    struct HtmlParserChar
      state : HtmlParserCharStateF
      mraw : MRawT
      replace_null : Bool
      drop_null : Bool
      is_attribute : Bool
      tmp : LibC::SizeT
      status : StatusT
      is_eof : Bool
      parse_errors : Void*
      entity : Void*
      entity_match : Void*
      entity_begin : UInt8*
      entity_str_len : LibC::SizeT
    end

    type HtmlParserCharT = HtmlParserChar*
    type HtmlParserCharStateF = HtmlParserCharT, StrT, UInt8*, UInt8* -> UInt8*

    fun html_parser_char_process = lxb_html_parser_char_process(pc : HtmlParserCharT, str : StrT, in_mode : InModeT, data : UInt8*, end : UInt8*) : StatusT
    fun html_parser_char_ref_data = lxb_html_parser_char_ref_data(pc : HtmlParserCharT, str : StrT, data : UInt8*, end : UInt8*) : UInt8*
    fun html_tokenizer_mraw = lxb_html_tokenizer_mraw_noi(tkz : HtmlTokenizerT) : MRawT
    fun str_destroy = lexbor_str_destroy(str : StrT, mraw : MRawT, obj : Bool) : StrT

    type HtmlTokenAttrTypeT = Int32
    type InNodeT = Void*

    struct HtmlTokenAttr
      name_begin : UInt8*
      name_end : UInt8*
      value_begin : UInt8*
      value_end : UInt8*
      in_name : InNodeT
      in_value : InNodeT
      next : HtmlTokenAttrT
      prev : HtmlTokenAttrT
      type : HtmlTokenAttrTypeT
    end

    type HtmlTokenAttrT = HtmlTokenAttr*
    fun html_token_attr_parse = lxb_html_token_attr_parse(attr : HtmlTokenAttrT, pc : HtmlParserCharT, name : StrT, value : StrT, mraw : MRawT) : StatusT
  end

  # const lxb_char_t *
  # lxb_dom_element_tag_name_noi(lxb_dom_element_t *element, size_t *len);
end
