ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all
  end
end

class ActionDispatch::IntegrationTest
  # Device fixtures use their own name as the raw token, see test/fixtures/devices.yml.
  def sign_in_as(device)
    cookies[Authentication::COOKIE] = device.to_s
  end
end
