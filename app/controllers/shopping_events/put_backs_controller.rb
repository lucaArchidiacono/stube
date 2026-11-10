# "Put back" in the history, and "Undo" after checking off or deleting.
class ShoppingEvents::PutBacksController < ApplicationController
  include ShoppingUndoBar

  def create
    event = Current.household.shopping_events.find(params[:shopping_event_id])
    item = event.put_back(by: Current.device)

    streams = [ turbo_stream.replace(event, partial: "shopping_events/shopping_event", locals: { shopping_event: event, put_back: false }) ]
    if item
      streams << turbo_stream.append("shopping_items", partial: "shopping_items/shopping_item", locals: { shopping_item: item })
      streams << undo_bar("#{item.name} is back on the list")
    else
      streams << undo_bar("#{event.item_name} is already on the list")
    end
    render turbo_stream: streams
  end
end
