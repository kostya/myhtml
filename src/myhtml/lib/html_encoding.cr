module Myhtml
  lib Lib
    type HtmlEncodingT = Void*

    struct HtmlEncodingEntryT
      name : UInt8*
      _end : UInt8*
    end

    fun html_encoding_create = lxb_html_encoding_create_noi : HtmlEncodingT
    fun html_encoding_init = lxb_html_encoding_init(em : HtmlEncodingT) : StatusT
    fun html_encoding_determine = lxb_html_encoding_determine(em : HtmlEncodingT, data : UInt8*, _end : UInt8*) : StatusT
    fun html_encoding_meta_entry = lxb_html_encoding_meta_entry_noi(em : HtmlEncodingT, idx : LibC::SizeT) : HtmlEncodingEntryT*
    fun html_encoding_meta_length = lxb_html_encoding_meta_length_noi(em : HtmlEncodingT) : LibC::SizeT
    fun html_encoding_destroy = lxb_html_encoding_destroy(em : HtmlEncodingT, self_destroy : Bool) : HtmlEncodingT

    fun html_encoding_content = lxb_html_encoding_content(data : UInt8*, _end : UInt8*, name_end : UInt8**) : UInt8*
  end
end
