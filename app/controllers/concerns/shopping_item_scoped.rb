# Loads the item from the current household. If someone else already checked
# it off or deleted it, there's nothing to do except take it off this page too.
module ShoppingItemScoped
  extend ActiveSupport::Concern

  included do
    before_action :set_shopping_item

    rescue_from ActiveRecord::RecordNotFound do
      render turbo_stream: turbo_stream.remove("shopping_item_#{params[:shopping_item_id] || params[:id]}")
    end
  end

  private
    def set_shopping_item
      @shopping_item = Current.household.shopping_items.find(params[:shopping_item_id] || params[:id])
    end
end
