require "spec"
require "../src/myhtml"
require "base64"

PAGE1  = File.read("./spec/fixtures/1.htm")
PAGE2  = File.read("./spec/fixtures/2.htm")
PAGE25 = File.read("./spec/fixtures/25.htm")

require "digest/md5"

def md5(str)
  Digest::MD5.hexdigest(str)
end

def str(array)
  String.new(array.to_unsafe, array.size)
end

def fixture(name)
  File.read("#{__DIR__}/fixtures/#{name}")
end

def unicoder(from_enc, text, replace_str = nil)
  Myhtml::EncodingConverter.new(from_enc, "utf-8", replace_str).convert(text)
end
