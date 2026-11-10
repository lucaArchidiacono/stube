# The shopping list's history: its own page on phone and tablet, and a lazy
# frame next to the list on desktop. "Show earlier" loads older pages into a
# frame of their own.
class ShoppingEventsController < ApplicationController
  def index
    scope = Current.household.shopping_events.newest_first
    scope = scope.where(id: ...params[:before].to_i) if params[:before].present?
    @events = scope.limit(ShoppingEvent::PAGE).to_a
    @names_on_list = Current.household.shopping_items.pluck(:name).map(&:downcase).to_set
  end
end
