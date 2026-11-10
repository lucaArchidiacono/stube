# Short codes people can read off a screen or type: 8 characters of Crockford
# base32, shown as XXXX-XXXX. Used for invites and the one-time setup code.
module Code
  ALPHABET = "0123456789ABCDEFGHJKMNPQRSTVWXYZ".chars.freeze

  extend self

  def generate
    from_bytes(SecureRandom.random_bytes(5))
  end

  # 5 bytes are 40 bits, which is exactly 8 characters of 5 bits.
  def from_bytes(bytes)
    number = bytes.unpack1("H*").to_i(16)
    characters = 8.times.map { |index| ALPHABET[(number >> (5 * (7 - index))) & 31] }.join
    "#{characters[0, 4]}-#{characters[4, 4]}"
  end

  # Forgiving about case, dashes and spaces, and about O, I and L, which people mix up with 0 and 1.
  def normalize(input)
    input.to_s.upcase.delete("^0-9A-Z").tr("OIL", "011")
  end

  def digest(code)
    Digest::SHA256.hexdigest(normalize(code))
  end
end
