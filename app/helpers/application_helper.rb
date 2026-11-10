module ApplicationHelper
  AVATAR_COLORS = [
    "bg-rose-100 text-rose-800 dark:bg-rose-900 dark:text-rose-100",
    "bg-amber-100 text-amber-800 dark:bg-amber-900 dark:text-amber-100",
    "bg-emerald-100 text-emerald-800 dark:bg-emerald-900 dark:text-emerald-100",
    "bg-sky-100 text-sky-800 dark:bg-sky-900 dark:text-sky-100",
    "bg-violet-100 text-violet-800 dark:bg-violet-900 dark:text-violet-100",
    "bg-lime-100 text-lime-800 dark:bg-lime-900 dark:text-lime-100"
  ].freeze

  AVATAR_SIZES = { sm: "size-8 text-xs", md: "size-10 text-sm", lg: "size-16 text-xl" }.freeze

  # Heroicons outline paths (MIT).
  ICONS = {
    home: "m2.25 12 8.954-8.955c.44-.439 1.152-.439 1.591 0L21.75 12M4.5 9.75v10.125c0 .621.504 1.125 1.125 1.125H9.75v-4.875c0-.621.504-1.125 1.125-1.125h2.25c.621 0 1.125.504 1.125 1.125V21h4.125c.621 0 1.125-.504 1.125-1.125V9.75M8.25 21h8.25",
    shopping: "M15.75 10.5V6a3.75 3.75 0 1 0-7.5 0v4.5m11.356-1.993 1.263 12c.07.665-.45 1.243-1.119 1.243H4.25a1.125 1.125 0 0 1-1.12-1.243l1.264-12A1.125 1.125 0 0 1 5.513 7.5h12.974c.576 0 1.059.435 1.119 1.007ZM8.625 10.5a.375.375 0 1 1-.75 0 .375.375 0 0 1 .75 0Zm7.5 0a.375.375 0 1 1-.75 0 .375.375 0 0 1 .75 0Z",
    household: "M15 19.128a9.38 9.38 0 0 0 2.625.372 9.337 9.337 0 0 0 4.121-.952 4.125 4.125 0 0 0-7.533-2.493M15 19.128v-.003c0-1.113-.285-2.16-.786-3.07M15 19.128v.106A12.318 12.318 0 0 1 8.624 21c-2.331 0-4.512-.645-6.374-1.766l-.001-.109a6.375 6.375 0 0 1 11.964-3.07M12 6.375a3.375 3.375 0 1 1-6.75 0 3.375 3.375 0 0 1 6.75 0Zm8.25 2.25a2.625 2.625 0 1 1-5.25 0 2.625 2.625 0 0 1 5.25 0Z",
    history: "M12 6v6h4.5m4.5 0a9 9 0 1 1-18 0 9 9 0 0 1 18 0Z",
    chevron_right: "m8.25 4.5 7.5 7.5-7.5 7.5",
    chevron_left: "M15.75 19.5 8.25 12l7.5-7.5",
    close: "M6 18 18 6M6 6l12 12"
  }.freeze

  def icon(name, css = "size-6")
    tag.svg(tag.path(d: ICONS.fetch(name), "stroke-linecap": "round", "stroke-linejoin": "round"),
      xmlns: "http://www.w3.org/2000/svg", fill: "none", viewBox: "0 0 24 24", "stroke-width": 1.5,
      stroke: "currentColor", class: css, "aria-hidden": true)
  end

  def initials(name)
    name.split.first(2).map { |word| word[0] }.join.upcase
  end

  # Initials on a color picked from the name. No photos at launch.
  def avatar(name, size: :md)
    tag.span(initials(name),
      class: "inline-flex shrink-0 items-center justify-center rounded-full font-semibold #{AVATAR_SIZES.fetch(size)} #{AVATAR_COLORS[name.sum % AVATAR_COLORS.size]}",
      "aria-hidden": true)
  end

  def day_name(date)
    if date == Date.current then "today"
    elsif date == Date.yesterday then "yesterday"
    else date.strftime("%a %-d %b")
    end
  end

  def last_seen(device)
    device.last_seen_on ? "seen #{day_name(device.last_seen_on)}" : "not seen yet"
  end

  def qr_code(text)
    RQRCode::QRCode.new(text).as_svg(module_size: 4, standalone: true, use_path: true, viewbox: true,
      svg_attributes: { class: "size-56 rounded-xl bg-white p-3", role: "img", "aria-label": "QR code" }).html_safe
  end
end
