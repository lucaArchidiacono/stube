require "test_helper"

class DevicesControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in_as :luca_mac }

  test "a member renames and removes a shared device" do
    patch device_path(devices(:kitchen)), params: { name: "Fridge iPad" }
    assert_equal "Fridge iPad", devices(:kitchen).reload.name

    delete device_path(devices(:kitchen))
    assert_redirected_to household_path
    assert_not Device.exists?(devices(:kitchen).id)
  end

  test "this device can't remove itself" do
    delete device_path(devices(:luca_mac))
    assert_response :forbidden
  end

  test "a shared device can't change devices" do
    sign_in_as :kitchen
    patch device_path(devices(:luca_iphone)), params: { name: "Mine" }
    assert_response :forbidden
  end
end
