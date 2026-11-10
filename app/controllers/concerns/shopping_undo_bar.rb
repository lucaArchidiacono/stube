# The bar at the bottom after checking off, deleting or putting back an item.
module ShoppingUndoBar
  private
    # With an event, the bar offers Undo, which puts that item back.
    def undo_bar(message, event: nil)
      turbo_stream.update "shopping_undo", partial: "shopping_events/undo", locals: { message:, event: }
    end
end
