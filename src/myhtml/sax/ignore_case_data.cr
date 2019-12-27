record Myhtml::SAX::IgnoreCaseData, name : Bytes do
  def self.new(s : String)
    self.new(s.to_slice)
  end

  forward_missing_to @name

  def hash
    h = 0
    name.each_byte do |c|
      c = normalize_byte(c)
      h = 31 * h + c
    end
    h
  end

  def to_s
    String.build(name.bytesize) do |buf|
      # appender = buf.appender
      name.each do |byte|
        buf.write_byte normalize_byte(byte)
      end
      {name.bytesize, name.bytesize}
    end
  end

  def ==(key2)
    key1 = name
    key2 = key2.name

    return false if key1.bytesize != key2.bytesize

    cstr1 = key1.to_unsafe
    cstr2 = key2.to_unsafe

    key1.bytesize.times do |i|
      next if cstr1[i] == cstr2[i] # Optimize the common case

      byte1 = normalize_byte(cstr1[i])
      byte2 = normalize_byte(cstr2[i])

      return false if byte1 != byte2
    end

    true
  end

  private def normalize_byte(byte)
    char = byte.unsafe_chr

    return byte if char.lowercase?
    return byte + 32 if char.uppercase?

    byte
  end
end
