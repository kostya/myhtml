module Myhtml
  @[Link(ldflags: "#{__DIR__}/../../ext/lexbor-c/build/liblexbor_static.a")]
  lib LibEncoding
    # cat src/ext/lexbor-c/source/lexbor/encoding/const.h | grep '    LXB_ENCODING' | ruby -e 'while s = gets; puts s.gsub(",", "").gsub("//", "#"); end;'
    enum EncodingT : UInt32
      LXB_ENCODING_DEFAULT        = 0x00
      LXB_ENCODING_AUTO           = 0x01
      LXB_ENCODING_UNDEFINED      = 0x02
      LXB_ENCODING_BIG5           = 0x03
      LXB_ENCODING_EUC_JP         = 0x04
      LXB_ENCODING_EUC_KR         = 0x05
      LXB_ENCODING_GBK            = 0x06
      LXB_ENCODING_IBM866         = 0x07
      LXB_ENCODING_ISO_2022_JP    = 0x08
      LXB_ENCODING_ISO_8859_10    = 0x09
      LXB_ENCODING_ISO_8859_13    = 0x0a
      LXB_ENCODING_ISO_8859_14    = 0x0b
      LXB_ENCODING_ISO_8859_15    = 0x0c
      LXB_ENCODING_ISO_8859_16    = 0x0d
      LXB_ENCODING_ISO_8859_2     = 0x0e
      LXB_ENCODING_ISO_8859_3     = 0x0f
      LXB_ENCODING_ISO_8859_4     = 0x10
      LXB_ENCODING_ISO_8859_5     = 0x11
      LXB_ENCODING_ISO_8859_6     = 0x12
      LXB_ENCODING_ISO_8859_7     = 0x13
      LXB_ENCODING_ISO_8859_8     = 0x14
      LXB_ENCODING_ISO_8859_8_I   = 0x15
      LXB_ENCODING_KOI8_R         = 0x16
      LXB_ENCODING_KOI8_U         = 0x17
      LXB_ENCODING_SHIFT_JIS      = 0x18
      LXB_ENCODING_UTF_16BE       = 0x19
      LXB_ENCODING_UTF_16LE       = 0x1a
      LXB_ENCODING_UTF_8          = 0x1b
      LXB_ENCODING_GB18030        = 0x1c
      LXB_ENCODING_MACINTOSH      = 0x1d
      LXB_ENCODING_REPLACEMENT    = 0x1e
      LXB_ENCODING_WINDOWS_1250   = 0x1f
      LXB_ENCODING_WINDOWS_1251   = 0x20
      LXB_ENCODING_WINDOWS_1252   = 0x21
      LXB_ENCODING_WINDOWS_1253   = 0x22
      LXB_ENCODING_WINDOWS_1254   = 0x23
      LXB_ENCODING_WINDOWS_1255   = 0x24
      LXB_ENCODING_WINDOWS_1256   = 0x25
      LXB_ENCODING_WINDOWS_1257   = 0x26
      LXB_ENCODING_WINDOWS_1258   = 0x27
      LXB_ENCODING_WINDOWS_874    = 0x28
      LXB_ENCODING_X_MAC_CYRILLIC = 0x29
      LXB_ENCODING_X_USER_DEFINED = 0x2a
      LXB_ENCODING_LAST_ENTRY     = 0x2b
    end

    type DataT = Void*
    type EncodeT = Void*
    type DecodeT = Void*
    type CodepointT = UInt32

    # Detect encoding name from user input
    fun data_by_name = lxb_encoding_data_by_name_noi(name : UInt8*, len : LibC::SizeT) : DataT
    fun data_by_pre_name = lxb_encoding_data_by_pre_name(name : UInt8*, len : LibC::SizeT) : DataT
    fun data_encoding = lxb_encoding_data_encoding_noi(data : DataT) : EncodingT
    fun data = lxb_encoding_data_noi(encoding : EncodingT) : DataT
    # TODO: add get name from data

    fun decode_init = lxb_encoding_decode_init_noi(decode : DecodeT, data : DataT, out : CodepointT*, len : LibC::SizeT) : Lib::StatusT
    fun decode_replace_set = lxb_encoding_decode_replace_set_noi(decode : DecodeT, replace : CodepointT*, len : LibC::SizeT) : Lib::StatusT

    fun encode_init = lxb_encoding_encode_init_noi(encode : EncodeT, data : DataT, buffer_out : UInt8*, buf_len : LibC::SizeT) : Lib::StatusT
    fun encode_replace_set = lxb_encoding_encode_replace_set_noi(encode : EncodeT, replace : UInt8*, len : LibC::SizeT) : Lib::StatusT

    fun decode_finish = lxb_encoding_decode_finish_noi(decode : DecodeT) : Lib::StatusT
    fun encode_finish = lxb_encoding_encode_finish_noi(encode : EncodeT) : Lib::StatusT
    fun encode_buf_used = lxb_encoding_encode_buf_used_noi(encode : EncodeT) : LibC::SizeT
    fun decode_buf_used = lxb_encoding_decode_buf_used_noi(decode : DecodeT) : LibC::SizeT

    fun decode_buf_used_set = lxb_encoding_decode_buf_used_set_noi(decode : DecodeT, used : LibC::SizeT)
    fun encode_buf_used_set = lxb_encoding_encode_buf_used_set_noi(encode : EncodeT, used : LibC::SizeT)

    fun data_call_encode = lxb_encoding_data_call_encode_noi(data : DataT, ctx : EncodeT, cp : CodepointT**, end : CodepointT*) : Lib::StatusT
    fun data_call_decode = lxb_encoding_data_call_decode_noi(data : DataT, ctx : DecodeT, data : UInt8**, end : UInt8*) : Lib::StatusT

    fun encode_t_sizeof = lxb_encoding_encode_t_sizeof : LibC::SizeT
    fun decode_t_sizeof = lxb_encoding_decode_t_sizeof : LibC::SizeT
  end
end
