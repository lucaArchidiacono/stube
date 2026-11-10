require "test_helper"
require "turbo/broadcastable/test_helper"

# What each change to the household sends to open pages.
class LiveUpdateBroadcastsTest < ActiveSupport::TestCase
  # turbo-rails only adds these once Action Cable has loaded, which depends on test order.
  include Turbo::Broadcastable::TestHelper

  setup { @settings = [ households(:ours), :settings ] }

  test "household pages refresh when the household, members, devices or invites change" do
    assert_turbo_stream_broadcasts(@settings, count: 1) { households(:ours).update!(name: "The flat") }
    assert_turbo_stream_broadcasts(@settings, count: 1) { members(:anna).update!(name: "Annie") }
    assert_turbo_stream_broadcasts(@settings, count: 1) { devices(:kitchen).update!(name: "Fridge iPad") }
    assert_turbo_stream_broadcasts(@settings, count: 1) { households(:ours).invites.create!(created_by: members(:luca)) }
  end

  test "being seen today doesn't refresh anything" do
    assert_no_turbo_stream_broadcasts(@settings) { devices(:luca_iphone).seen }
  end

  test "a removed device's open pages refresh, so they land on Join" do
    device = devices(:anna_iphone)
    assert_turbo_stream_broadcasts(device, count: 1) { device.destroy! }
    assert_equal "refresh", capture_turbo_stream_broadcasts(device).last["action"]
  end

  test "removing a member refreshes the pages of each of their devices" do
    anna_iphone = devices(:anna_iphone)
    assert_turbo_stream_broadcasts(anna_iphone, count: 1) { members(:anna).destroy! }
  end
end
