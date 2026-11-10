require "test_helper"

class DisconnectDeviceJobTest < ActiveJob::TestCase
  include ActionCable::TestHelper
  test "removing a device closes its live connection a few seconds later" do
    device = devices(:anna_iphone)
    assert_enqueued_with(job: DisconnectDeviceJob, args: [ device.to_gid_param ]) { device.destroy! }
  end

  test "the connection of that device is told to disconnect for good" do
    gid = devices(:anna_iphone).to_gid_param
    assert_broadcast_on("action_cable/#{gid}", { type: "disconnect", reconnect: false }) do
      DisconnectDeviceJob.perform_now(gid)
    end
  end
end
