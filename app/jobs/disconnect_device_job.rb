# Closes a removed device's live connection, so it receives nothing more and
# can't reconnect. Runs a few seconds after the removal: closing right away
# would overtake the refresh that sends its open pages to Join.
class DisconnectDeviceJob < ApplicationJob
  DELAY = 5.seconds

  # The device is already gone, so it comes as its GlobalID string, which is
  # also what identifies its connection.
  def perform(device_gid)
    ActionCable.server.remote_connections.where(device: device_gid).disconnect(reconnect: false)
  end
end
