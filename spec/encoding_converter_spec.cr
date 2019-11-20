require "./spec_helper"

WORD1 = "\xEF\xF0\xE8\xE2\xE5\xF2"
WORD2 = "привет"

describe Myhtml::EncodingConverter do
  context "simple converts" do
    it "convert from string to string" do
      Myhtml::EncodingConverter.new("cp1251", "utf-8").convert(WORD1).should eq WORD2
    end

    it "convert from slice to string" do
      Myhtml::EncodingConverter.new("cp1251", "utf-8").convert(WORD1.to_slice).should eq WORD2
    end

    it "convert from io to string" do
      Myhtml::EncodingConverter.new("cp1251", "utf-8").convert(IO::Memory.new(WORD1)).should eq WORD2
    end

    it "convert from string to io" do
      String.build do |buf|
        Myhtml::EncodingConverter.new("cp1251", "utf-8").convert(WORD1) do |slice|
          buf.write(slice)
        end
      end.should eq WORD2
    end

    it "convert from slice to io" do
      String.build do |buf|
        Myhtml::EncodingConverter.new("cp1251", "utf-8").convert(WORD1.to_slice) do |slice|
          buf.write(slice)
        end
      end.should eq WORD2
    end

    it "convert from io to io" do
      String.build do |buf|
        Myhtml::EncodingConverter.new("cp1251", "utf-8").convert(IO::Memory.new(WORD1)) do |slice|
          buf.write(slice)
        end
      end.should eq WORD2
    end
  end

  it "message more than buffer" do
    Myhtml::EncodingConverter.new("cp1251", "utf-8").convert(WORD1 * 10000).should eq WORD2 * 10000
  end

  it "allow init from constants" do
    Myhtml::EncodingConverter.new(Myhtml::LibEncoding::EncodingT::LXB_ENCODING_WINDOWS_1251,
      Myhtml::LibEncoding::EncodingT::LXB_ENCODING_UTF_8).convert(WORD1).should eq WORD2
  end

  context "replace" do
    it "default" do
      unicoder("utf-8", str(UInt8[116, 101, 115, 116, 242, 229, 241, 242, 116, 101, 115, 116])).should eq "test����test"
    end

    it "empty" do
      Myhtml::EncodingConverter.new("utf-8", "utf-8", "").convert(str(UInt8[116, 101, 115, 116, 242, 229, 241, 242, 116, 101, 115, 116])).should eq "testtest"
    end

    it "custom" do
      Myhtml::EncodingConverter.new("utf-8", "utf-8", "-").convert(str(UInt8[116, 101, 115, 116, 242, 229, 241, 242, 116, 101, 115, 116])).should eq "test----test"
    end
  end

  context "encoding cases" do
    it { unicoder("utf-8", "текст").should eq "текст" }
    it { unicoder("cp1251", str(UInt8[242, 229, 241, 242])).should eq "тест" }
    it { unicoder("KOI8-R", str(UInt8[212, 197, 211, 212])).should eq "тест" }
    it { unicoder("KOI8-U", str(UInt8[245, 203, 210, 193, 167, 206, 211, 216, 203, 193, 32, 205, 207, 215, 193, 32, 206, 193, 204, 197, 214, 201, 212, 216, 32, 196, 207, 32, 166, 206, 196, 207, 164, 215, 210, 207, 208, 197, 202, 211, 216, 203, 207, 167, 32, 205, 207, 215, 206, 207, 167, 32, 210, 207, 196, 201, 206, 201])).should eq "Українська мова належить до індоєвропейської мовної родини" }
    it { unicoder("iso8859-1", str(UInt8[114, 233, 115, 117, 109, 233])).should eq "résumé" }
    it { unicoder("windows-1252", str(UInt8[114, 233, 115, 117, 109, 233])).should eq "résumé" }
    it { unicoder("tis-620", str(UInt8[170, 232, 210, 167, 225, 205, 195, 236])).should eq "ช่างแอร์" }
    it { unicoder("windows-874", str(UInt8[188, 197, 161, 210, 195, 180, 211, 224, 185, 212, 185, 167, 210, 185])).should eq "ผลการดำเนินงาน" }
    it { unicoder("utf-8", str(UInt8[116, 101, 115, 116, 242, 229, 241, 242, 116, 101, 115, 116])).should eq "test����test" }
    it { unicoder("utf-8", fixture("bad_encoding.htm")).should contain("SEARCHAREA") }

    it do
      res = unicoder("WINDOWS-1251", fixture("bad_encoding2.htm"))
      res.should contain("Груздовский карьер")
      res.bytesize.should eq 99258
    end

    it { Myhtml::EncodingConverter.new("utf-8", "utf-8", "").convert(Base64.decode_string("ey8qx+Tl8fwg7+Dw4Ozl8vD7IOLo5+jy4CovfQ==")).should eq "{/*  */}" }
    it { unicoder("utf-8", fixture("1.png")).bytesize.should be > 0 }
    it { unicoder("utf-8", fixture("1.png.gz")).bytesize.should be > 0 }
  end
end
