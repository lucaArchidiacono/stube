class DevicesController < ApplicationController
  require_member only: %i[update destroy]
  before_action :set_device

  # A live refresh can land here after someone removed this device.
  rescue_from ActiveRecord::RecordNotFound do
    redirect_to household_path, alert: "That device is no longer in the household."
  end

  def show
  end

  def update
    if @device.update(name: params[:name])
      redirect_to device_path(@device), notice: "Saved.", status: :see_other
    else
      redirect_to device_path(@device), alert: @device.errors.full_messages.to_sentence, status: :see_other
    end
  end

  # This device leaves through "Leave household" instead.
  def destroy
    return head :forbidden if @device == Current.device

    @device.destroy!
    redirect_to(@device.member ? member_path(@device.member) : household_path, notice: "#{@device.name} was removed.", status: :see_other)
  end

  private
    def set_device
      @device = Current.household.devices.find(params[:id])
    end
end
