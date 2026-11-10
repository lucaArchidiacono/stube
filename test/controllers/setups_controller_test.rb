require "test_helper"

class SetupsControllerTest < ActionDispatch::IntegrationTest
  setup { Household.destroy_all }

  test "a new server sends everyone to the setup" do
    get root_path
    assert_redirected_to new_setup_path

    get join_path(code: "AAAA-BBBB")
    assert_redirected_to new_setup_path
  end

  test "the wrong setup code is refused" do
    post setup_path, params: { code: "0000-0000", name: "Luca", household_name: "Our home" }
    assert_response :unprocessable_entity
    assert_equal 0, Household.count
  end

  test "the setup code creates the household, the first member and this device" do
    post setup_path, params: { code: Household.setup_code, name: "Luca", household_name: "Our home", time_zone: "Europe/Zurich" },
      headers: { "User-Agent" => "Mozilla/5.0 (Macintosh) AppleWebKit/605.1.15 Version/18.0 Safari/605.1.15" }
    assert_redirected_to root_path

    household = Household.sole
    assert_equal [ "Our home", "Europe/Zurich" ], [ household.name, household.time_zone ]
    assert_equal "Luca", household.members.sole.name
    assert_equal "Safari on Mac", household.devices.sole.name

    follow_redirect!
    assert_response :success
  end

  test "a missing name is reported and nothing is created" do
    post setup_path, params: { code: Household.setup_code, name: "", household_name: "Our home" }
    assert_response :unprocessable_entity
    assert_equal 0, Household.count
  end

  test "the setup is closed once a household exists" do
    Household.create!(name: "Our home", time_zone: "UTC")
    get new_setup_path
    assert_redirected_to root_path
  end
end
