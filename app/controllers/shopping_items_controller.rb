# The shopping list. Responses update this page right away; everyone else gets
# the same change through the live stream (see ShoppingItem).
class ShoppingItemsController < ApplicationController
  include ShoppingItemScoped, ShoppingUndoBar
  skip_before_action :set_shopping_item, only: %i[index create]

  def index
    @shopping_items = Current.household.shopping_items.ordered
  end

  def create
    item = Current.household.shopping_items.add(params[:name], by: Current.device)
    render turbo_stream: turbo_stream.append("shopping_items", item)
  rescue ActiveRecord::RecordInvalid
    render turbo_stream: [], status: :unprocessable_entity
  end

  # An empty name changes nothing. Deleting is its own button.
  def update
    @shopping_item.rename(params[:name], by: Current.device) if params[:name].present?
    render turbo_stream: turbo_stream.replace(@shopping_item)
  rescue ActiveRecord::RecordInvalid
    render turbo_stream: turbo_stream.replace(@shopping_item.reload)
  end

  def destroy
    event = @shopping_item.remove(by: Current.device)
    render turbo_stream: [ turbo_stream.remove(@shopping_item), undo_bar("#{event.item_name} deleted", event:) ]
  end
end
