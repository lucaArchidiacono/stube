require "test_helper"

class HouseholdTest < ActiveSupport::TestCase
  test "the setup code is stable and accepted however it's typed" do
    code = Household.setup_code
    assert_equal code, Household.setup_code
    assert Household.setup_code?(code.downcase.delete("-"))
    assert_not Household.setup_code?("0000-0000")
    assert_not Household.setup_code?(nil)
  end

  test "an unknown time zone falls back to UTC" do
    assert_equal "Europe/Zurich", Household.time_zone_or_utc("Europe/Zurich")
    assert_equal "UTC", Household.time_zone_or_utc("Mars/Olympus_Mons")
    assert_equal "UTC", Household.time_zone_or_utc(nil)
  end

  test "the time zone must exist" do
    assert_not Household.new(name: "Home", time_zone: "Mars/Olympus_Mons").valid?
  end

  test "removing a household removes everything in it" do
    households(:ours).destroy!
    assert_equal 0, Member.count + Device.count + Invite.count
  end
end
