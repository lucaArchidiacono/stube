module ShoppingEventsHelper
  def shopping_event_sentence(event)
    strong = ->(text) { tag.strong(text, class: "font-medium") }
    by, item = strong.(event.by_name), strong.(event.item_name)

    case event.action.to_sym
    when :added then safe_join([ by, " added ", item ])
    when :renamed then safe_join([ by, " changed ", strong.(event.old_item_name), " to ", item ])
    when :checked_off then safe_join([ by, " checked off ", item ])
    when :deleted then safe_join([ by, " deleted ", item ])
    when :put_back then safe_join([ by, " put back ", item ])
    end
  end

  def history_day(date, today)
    if date == today then "Today"
    elsif date == today - 1 then "Yesterday"
    else date.strftime("%a %-d %b")
    end
  end
end
