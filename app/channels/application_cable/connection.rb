module ApplicationCable
  # Live updates need the same device cookie as every page. Removed devices are
  # refused, and their open connections are closed when they're removed.
  class Connection < ActionCable::Connection::Base
    identified_by :device

    def connect
      self.device = Device.authenticate(cookies[Authentication::COOKIE]) || reject_unauthorized_connection
    end
  end
end
