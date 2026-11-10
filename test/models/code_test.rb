require "test_helper"

class CodeTest < ActiveSupport::TestCase
  test "codes are 8 readable characters with a dash" do
    assert_match(/\A[0-9A-HJKMNP-TV-Z]{4}-[0-9A-HJKMNP-TV-Z]{4}\z/, Code.generate)
  end

  test "typing is forgiving about case, dashes, spaces and look-alike letters" do
    assert_equal Code.digest("K7Q2-9XP0"), Code.digest(" k7q2 9xpo ")
    assert_equal Code.digest("1111-0000"), Code.digest("ILil-OoOo")
  end
end
