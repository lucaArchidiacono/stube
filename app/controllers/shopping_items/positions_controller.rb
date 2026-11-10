# Sorting by hand. The page already moved the item, so there's nothing to send back.
class ShoppingItems::PositionsController < ApplicationController
  include ShoppingItemScoped

  def update
    @shopping_item.move_to(params[:position])
    render turbo_stream: []
  end
end
