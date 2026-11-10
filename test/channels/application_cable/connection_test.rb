require "test_helper"

class ApplicationCable::ConnectionTest < ActionCable::Connection::TestCase
  test "a device connects with its cookie" do
    cookies[Authentication::COOKIE] = "luca_mac"
    connect
    assert_equal devices(:luca_mac), connection.device
  end

  test "the connection is known by the device's GlobalID, which DisconnectDeviceJob targets" do
    cookies[Authentication::COOKIE] = "luca_mac"
    connect
    assert_equal devices(:luca_mac).to_gid_param, connection.connection_identifier
  end

  test "without a device there are no live updates" do
    assert_reject_connection { connect }

    cookies[Authentication::COOKIE] = "removed"
    assert_reject_connection { connect }
  end
end
