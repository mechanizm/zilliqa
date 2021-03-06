module Zilliqa
  module Util
    extend self

    def pack(a, b)
      a << 16 + b
    end

    def encode_hex(b)
      b.unpack('H*').first
    end

    def decode_hex(s)
      [s].pack('H*')
    end
  end
end
