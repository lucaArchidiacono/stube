class ShoppingItems::CheckOffsController < ApplicationController
  include ShoppingItemScoped, ShoppingUndoBar

  def create
    event = @shopping_item.check_off(by: Current.device)
    render turbo_stream: [ turbo_stream.remove(@shopping_item), undo_bar("#{event.item_name} checked off", event:) ]
  end
end
