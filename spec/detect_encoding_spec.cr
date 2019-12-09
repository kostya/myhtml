require "./spec_helper"

def assoc_encoding(s)
  Myhtml::Utils::DetectEncoding.assoc_encoding_with_additionals(s)
end

def find_encodings_in_meta(html)
  Myhtml::Utils::DetectEncoding.find_encodings_in_meta(html.to_slice)
end

def find_in_header_value(str)
  Myhtml::Utils::DetectEncoding.find_in_header_value(str.to_slice)
end

def html_detect_encoding_and_convert(*args, **args2)
  enc, tp, cont, encs = Myhtml::Utils::DetectEncoding.html_detect_encoding_and_convert(*args, **args2)

  {enc.to_s.sub("LXB_ENCODING_", ""), tp, cont, encs.join(", ")}
end

GOOD_NAMES = ["UTF-8", "WINDOWS-1251", "CP1251", "ISO-8859-1", "UTF8", "KOI8-R", "KOI8-U", "ISO-8859-5", "GB2312", "US-ASCII",
              "WINDOWS-1252", "GBK", "WINDOWS-874", "EUC-KR", "MACCYRILLIC", "WINDOWS-1250", "ISO-8859-2", "SHIFT_JIS", "EUC-JP", "ASCII",
              "LATIN1", "WINDOWS-1257", "ISO-8859-15", "KOI8-RU", "WINDOWS-1254"]

CASES = {"utf-8"        => Myhtml::LibEncoding::EncodingT::LXB_ENCODING_UTF_8,
         "utf8"         => Myhtml::LibEncoding::EncodingT::LXB_ENCODING_UTF_8,
         "koi8-r"       => Myhtml::LibEncoding::EncodingT::LXB_ENCODING_KOI8_R,
         "koi8-u"       => Myhtml::LibEncoding::EncodingT::LXB_ENCODING_KOI8_U,
         "iso-8859-5"   => Myhtml::LibEncoding::EncodingT::LXB_ENCODING_ISO_8859_5,
         "iso8859-5"    => Myhtml::LibEncoding::EncodingT::LXB_ENCODING_ISO_8859_5,
         "iso-8859-1"   => Myhtml::LibEncoding::EncodingT::LXB_ENCODING_WINDOWS_1252,
         "iso8859-1"    => Myhtml::LibEncoding::EncodingT::LXB_ENCODING_WINDOWS_1252,
         "cp866"        => Myhtml::LibEncoding::EncodingT::LXB_ENCODING_IBM866,
         "cp-866"       => Myhtml::LibEncoding::EncodingT::LXB_ENCODING_IBM866,
         "ibm866"       => Myhtml::LibEncoding::EncodingT::LXB_ENCODING_IBM866,
         "ibm-866"      => Myhtml::LibEncoding::EncodingT::LXB_ENCODING_IBM866,
         "euc-jp"       => Myhtml::LibEncoding::EncodingT::LXB_ENCODING_EUC_JP,
         "us-ascii"     => Myhtml::LibEncoding::EncodingT::LXB_ENCODING_WINDOWS_1252,
         "iso-8859-2"   => Myhtml::LibEncoding::EncodingT::LXB_ENCODING_ISO_8859_2,
         "iso-8859-7"   => Myhtml::LibEncoding::EncodingT::LXB_ENCODING_ISO_8859_7,
         "shift_jis"    => Myhtml::LibEncoding::EncodingT::LXB_ENCODING_SHIFT_JIS,
         "tis-620"      => Myhtml::LibEncoding::EncodingT::LXB_ENCODING_WINDOWS_874,
         "windows-874"  => Myhtml::LibEncoding::EncodingT::LXB_ENCODING_WINDOWS_874,
         "WIN-1251"     => Myhtml::LibEncoding::EncodingT::LXB_ENCODING_WINDOWS_1251,
         "ISO-8859-1"   => Myhtml::LibEncoding::EncodingT::LXB_ENCODING_WINDOWS_1252,
         "Windows-1254" => Myhtml::LibEncoding::EncodingT::LXB_ENCODING_WINDOWS_1254,
         "tis-620"      => Myhtml::LibEncoding::EncodingT::LXB_ENCODING_WINDOWS_874,
         "windows-874"  => Myhtml::LibEncoding::EncodingT::LXB_ENCODING_WINDOWS_874,
         "cp_1251"      => Myhtml::LibEncoding::EncodingT::LXB_ENCODING_WINDOWS_1251,
}

SIMILAR = {
  "iso88595"  => Myhtml::LibEncoding::EncodingT::LXB_ENCODING_ISO_8859_5,
  "iso-88595" => Myhtml::LibEncoding::EncodingT::LXB_ENCODING_ISO_8859_5,
  "iso88591"  => Myhtml::LibEncoding::EncodingT::LXB_ENCODING_WINDOWS_1252,
  "iso-88591" => Myhtml::LibEncoding::EncodingT::LXB_ENCODING_WINDOWS_1252,
  "koi8"      => Myhtml::LibEncoding::EncodingT::LXB_ENCODING_KOI8_R,
  "koi8u"     => Myhtml::LibEncoding::EncodingT::LXB_ENCODING_KOI8_U,
  "koi8r"     => Myhtml::LibEncoding::EncodingT::LXB_ENCODING_KOI8_R,
}

ALIASES = {
  "ansi"    => Myhtml::LibEncoding::EncodingT::LXB_ENCODING_WINDOWS_1252,
  "dos-866" => Myhtml::LibEncoding::EncodingT::LXB_ENCODING_IBM866,
  "dos866"  => Myhtml::LibEncoding::EncodingT::LXB_ENCODING_IBM866,
  "Unicode" => Myhtml::LibEncoding::EncodingT::LXB_ENCODING_UTF_8,
}

MISTAKES = {"uft8"  => Myhtml::LibEncoding::EncodingT::LXB_ENCODING_UTF_8,
            "uft-8" => Myhtml::LibEncoding::EncodingT::LXB_ENCODING_UTF_8,
            "utf"   => Myhtml::LibEncoding::EncodingT::LXB_ENCODING_UTF_8,
            # "urf-8"           => Myhtml::LibEncoding::EncodingT::LXB_ENCODING_UTF_8,
            "windows 1251" => Myhtml::LibEncoding::EncodingT::LXB_ENCODING_WINDOWS_1251,
            # "coi8-r"          => Myhtml::LibEncoding::EncodingT::LXB_ENCODING_KOI8_R,
            "koi8-ru"         => Myhtml::LibEncoding::EncodingT::LXB_ENCODING_KOI8_U,
            "windows-cp1251"  => Myhtml::LibEncoding::EncodingT::LXB_ENCODING_WINDOWS_1251,
            "windos-1251"     => Myhtml::LibEncoding::EncodingT::LXB_ENCODING_WINDOWS_1251,
            "window-1251"     => Myhtml::LibEncoding::EncodingT::LXB_ENCODING_WINDOWS_1251,
            "(UTF-8)"         => Myhtml::LibEncoding::EncodingT::LXB_ENCODING_UTF_8,
            "utf-8,text/html" => Myhtml::LibEncoding::EncodingT::LXB_ENCODING_UTF_8,
            # "pc1251"          => Myhtml::LibEncoding::EncodingT::LXB_ENCODING_WINDOWS_1251,
            "'UTF-8'"          => Myhtml::LibEncoding::EncodingT::LXB_ENCODING_UTF_8,
            "utf-8; dir=rtl"   => Myhtml::LibEncoding::EncodingT::LXB_ENCODING_UTF_8,
            "cp_1251; dir=rtl" => Myhtml::LibEncoding::EncodingT::LXB_ENCODING_WINDOWS_1251,
}

NOTHING = {"aasdfadsfd" => nil, "charset=utf-8" => nil,
           "urFI" => nil, "asfd" => nil, "" => nil, "a" => nil, "_" => nil,
           "_crap" => nil,
}

describe Myhtml::Utils::DetectEncoding do
  context "assoc_encoding" do
    it { assoc_encoding("what?").should eq nil }
    it { assoc_encoding("_crap").should eq nil }
    it { assoc_encoding("us-ascii").should eq Myhtml::LibEncoding::EncodingT::LXB_ENCODING_WINDOWS_1252 }
    it { assoc_encoding("iso8859-1").should eq Myhtml::LibEncoding::EncodingT::LXB_ENCODING_WINDOWS_1252 }
    it { assoc_encoding("Latin1").should eq Myhtml::LibEncoding::EncodingT::LXB_ENCODING_WINDOWS_1252 }
    it { assoc_encoding("utf-8").should eq Myhtml::LibEncoding::EncodingT::LXB_ENCODING_UTF_8 }
    it { assoc_encoding(" cp1251").should eq Myhtml::LibEncoding::EncodingT::LXB_ENCODING_WINDOWS_1251 }
    it { assoc_encoding("Windows-1251").should eq Myhtml::LibEncoding::EncodingT::LXB_ENCODING_WINDOWS_1251 }
    it { assoc_encoding("koi8-RU").should eq Myhtml::LibEncoding::EncodingT::LXB_ENCODING_KOI8_U }
  end

  context "assoc_encoding2" do
    GOOD_NAMES.each do |k|
      it "GOOD_NAMES should find for '#{k}'" do
        assoc_encoding(k).should_not be_nil
      end
    end

    CASES.each do |k, v|
      it "CASES should find '#{v}' for '#{k}'" do
        assoc_encoding(k).should eq v
      end
    end

    SIMILAR.each do |k, v|
      it "SIMILAR should find '#{v}' for '#{k}'" do
        assoc_encoding(k).should eq v
      end
    end

    ALIASES.each do |k, v|
      it "ALIASES should find '#{v}' for '#{k}'" do
        assoc_encoding(k).should eq v
      end
    end

    MISTAKES.each do |k, v|
      pending "MISTAKES should find '#{v}' for '#{k}'" do
        assoc_encoding(k).should eq v
      end
    end

    NOTHING.each do |k, v|
      it "NOTHING should find '#{v}' for '#{k}'" do
        assoc_encoding(k).should eq v
      end
    end
  end

  context "find_encodings_in_meta" do
    it { find_encodings_in_meta(%{<head><meta charset="windows-1251"></head>текст}).should eq ["windows-1251"] }
    it { find_encodings_in_meta(%{<head><meta charset='utf8'></head>текст}).should eq ["utf8"] }
    it { find_encodings_in_meta(%{<head><meta charset=koi8r></head>текст}).should eq ["koi8r"] }
    it { find_encodings_in_meta(%{<head><meta charset="us-ascii"></head>текст}).should eq ["us-ascii"] }
    it { find_encodings_in_meta(%{<head><meta name="Content-type" content="text/html; charset=utf-8"></head>текст}).should eq ["utf-8"] }
    it { find_encodings_in_meta(%{<meta http-equiv="Content-type" content="text/html; charset=utf-8">текст}).should eq ["utf-8"] }
    it { find_encodings_in_meta(%{<meta http-equiv="Content-type" content="text/html;> charset=utf-8">текст}).should eq ["utf-8"] }
    it { find_encodings_in_meta(%{<meta name="blah"> <script charset="utf8"></script>текст}).should eq([] of String) }
    it { find_encodings_in_meta(%{<meta http-equiv="Content-type" content="text/html; charset=utf-8; dir=rtl">текст}).should eq ["utf-8"] }
    it do
      page = <<-HTML
        <meta http-equiv="Content-type" content="text/html; charset=CRAP">
        <meta http-equiv="Content-type" content="text/html; charset=utf-8">
        <meta http-equiv="Content-type" content="text/html; charset=cp1251">текст
      HTML
      find_encodings_in_meta(page).should eq ["CRAP", "utf-8", "cp1251"]
    end
    it do
      page = <<-HTML
        <html><head>
        <!--<meta http-equiv="Content-type" content="text/html; charset=cp1251">-->
        <meta http-equiv="Content-type" content="text/html; charset=utf-8">
        </head><body>
          текст
        </body>
      HTML
      find_encodings_in_meta(page).should eq ["utf-8"]
    end

    it { find_encodings_in_meta(fixture("bad_encoding.htm")).should eq ["windows-1251"] }
    it { find_encodings_in_meta(fixture("bad_encoding2.htm")).should eq ["_CHARSET", "windows-1251"] }
    it { find_encodings_in_meta(fixture("bug.htm")).should eq ["windows-1252"] }
    it { find_encodings_in_meta(fixture("th.htm")).should eq ["tis-620"] }
    it { find_encodings_in_meta(fixture("unk.htm")).should eq ["utf-8"] }
    it { find_encodings_in_meta(fixture("25.htm")).should eq ["windows-1251"] }
    it { find_encodings_in_meta(fixture("1.png")).should eq ([] of String) }
    it { find_encodings_in_meta(fixture("1.png.gz")).should eq([] of String) }
  end

  context "find_in_header_value" do
    it { find_in_header_value("text/html; charset=UTF-8").should eq "UTF-8" }
    it { find_in_header_value("text/html; charset= UTF-8").should eq "UTF-8" }

    it { find_in_header_value("text/html; charset='Windows-1251' ").should eq "Windows-1251" }
    it { find_in_header_value("  text/html; charset=koi8r   ").should eq "koi8r" }
    it { find_in_header_value("Content-type: text/html;charset=_crap").should eq "_crap" }
    it { find_in_header_value("Content-type: text/html; charset=ANSI").should eq "ANSI" }
    it { find_in_header_value("Content-type: text/html; charset=\"Unicode\"").should eq "Unicode" }
    it { find_in_header_value("Content-type: text/html; charset=iso8859-1").should eq "iso8859-1" }

    it { find_in_header_value("Content-type: text/html; charset=Windows-1251;ref").should eq "Windows-1251" }
    it { find_in_header_value("Content-type: text/html; charset=Windows-1251&ref").should eq "Windows-1251&ref" }
    it { find_in_header_value("Content-type: text/html; charset=utf-8; dir=rtl").should eq "utf-8" }
  end

  context "html_detect_encoding_and_convert" do
    context "options usage" do
      it { html_detect_encoding_and_convert("текст").should eq({"", nil, "текст", ""}) }
      it { html_detect_encoding_and_convert("\xEF\xF0\xE8\xE2\xE5\xF2-bla").should eq({"", nil, "-bla", ""}) }

      it { html_detect_encoding_and_convert("\xEF\xF0\xE8\xE2\xE5\xF2-bla", default: "cp1251").should eq({"WINDOWS_1251", :default, "привет-bla", ""}) }
      it { html_detect_encoding_and_convert("\xEF\xF0\xE8\xE2\xE5\xF2-bla", default: Myhtml::LibEncoding::EncodingT::LXB_ENCODING_WINDOWS_1251).should \
        eq({"WINDOWS_1251", :default, "привет-bla", ""}) }

      it { html_detect_encoding_and_convert("привет-bla", from: "utf-8", to: "cp1251").should eq({"UTF_8", :from, "\xEF\xF0\xE8\xE2\xE5\xF2-bla", ""}) }
      it { html_detect_encoding_and_convert("привет-bla", from: "utf-8", to: Myhtml::LibEncoding::EncodingT::LXB_ENCODING_WINDOWS_1251).should \
        eq({"UTF_8", :from, "\xEF\xF0\xE8\xE2\xE5\xF2-bla", ""}) }

      it { html_detect_encoding_and_convert("\xEF\xF0\xE8\xE2\xE5\xF2-bla", from: "cp1251").should eq({"WINDOWS_1251", :from, "привет-bla", ""}) }
      it { html_detect_encoding_and_convert("\xEF\xF0\xE8\xE2\xE5\xF2-bla", from: Myhtml::LibEncoding::EncodingT::LXB_ENCODING_WINDOWS_1251).should \
        eq({"WINDOWS_1251", :from, "привет-bla", ""}) }

      it { html_detect_encoding_and_convert("\xEF\xF0\xE8\xE2\xE5\xF2-bla", replace: "?").should eq({"", nil, "??????-bla", ""}) }

      it { html_detect_encoding_and_convert("\xEF\xF0\xE8\xE2\xE5\xF2-bla", content_type: "text/html; charset='Windows-1251' ").should \
        eq({"WINDOWS_1251", :header, "привет-bla", ""}) }

      it { html_detect_encoding_and_convert(%Q{<head><meta charset="windows-1251"></head>\xEF\xF0\xE8\xE2\xE5\xF2}).should \
        eq({"WINDOWS_1251", :meta, "<head><meta charset=\"windows-1251\"></head>привет", ""}) }
    end

    context "order of execution" do
      it "first choose encoding from content over meta" do
        html_detect_encoding_and_convert(%Q{<head><meta charset="utf-8"></head>\xEF\xF0\xE8\xE2\xE5\xF2}, content_type: "text/html; charset=cp1251").should \
          eq({"WINDOWS_1251", :header, "<head><meta charset=\"utf-8\"></head>привет", ""})
      end

      it "if header have crap, use meta" do
        html_detect_encoding_and_convert(%Q{<head><meta charset="windows-1251"></head>\xEF\xF0\xE8\xE2\xE5\xF2}, content_type: "text/html; charset=crap").should \
          eq({"WINDOWS_1251", :meta, "<head><meta charset=\"windows-1251\"></head>привет", "crap"})
      end

      it "choose from over header" do
        html_detect_encoding_and_convert(%Q{\xEF\xF0\xE8\xE2\xE5\xF2}, from: "cp1251", content_type: "text/html; charset=utf-8").should \
          eq({"WINDOWS_1251", :from, "привет", ""})
      end

      it "if meta and header have crap, use default" do
        html_detect_encoding_and_convert(%Q{<head><meta charset="_crap1"></head>\xEF\xF0\xE8\xE2\xE5\xF2}, content_type: "text/html; charset=crap2", default: "cp1251").should \
          eq({"WINDOWS_1251", :default, "<head><meta charset=\"_crap1\"></head>привет", "crap2, _crap1"})
      end

      it "picks the first correct encoding from meta" do
        page = <<-HTML
          <meta http-equiv="Content-type" content="text/html; charset=CRAP">
          <meta http-equiv="Content-type" content="text/html; charset=cp1251">
          <meta http-equiv="Content-type" content="text/html; charset=utf-8">
          \xEF\xF0\xE8\xE2\xE5\xF2
        HTML
        a, b, c, d = html_detect_encoding_and_convert(page, content_type: "text/html; charset=crap2", default: "tis-620")
        a.should eq "WINDOWS_1251"
        b.should eq :meta
        c.should contain("привет")
        d.should eq "crap2, CRAP"
      end
    end

    context "complex cases" do
      [0, 1, 10, 100, 1000, 1500, 2000, 3500, 4000, 10000].each do |header_size|
        [0, 1000, 10000, 100000, 1_000_000].each do |body_size|
          context "{#{header_size}, #{body_size}}" do
            it "no encoding" do
              tag = "<meta charset=utf8>"
              str = "a" * header_size + tag + "b" * body_size

              a, b, c, d = html_detect_encoding_and_convert(str, default: "utf-8")

              if header_size > Myhtml::Utils::DetectEncoding::META_CHECK_LIMIT_BYTES + tag.size
                a.should eq "UTF_8"
                b.should eq :default
              else
                a.should eq "UTF_8"
                b.should eq :meta
              end
              c.should eq str
            end

            it "from cp1251" do
              tag = "<meta charset=cp-1251>" + str(UInt8[242, 229, 234, 241, 242])
              str = "a" * header_size + tag + "b" * body_size

              a, b, page, d = html_detect_encoding_and_convert(str, default: "utf-8")

              if header_size > Myhtml::Utils::DetectEncoding::META_CHECK_LIMIT_BYTES + tag.size
                {a, b}.should eq({"UTF_8", :default})
                page.bytesize.should eq header_size + body_size + 22
                page.includes?("текст").should eq false
              else
                {a, b}.should eq({"WINDOWS_1251", :meta})
                page.bytesize.should eq header_size + body_size + 32
                page.includes?("текст").should eq true
              end
            end
          end
        end
      end
    end
  end
end
