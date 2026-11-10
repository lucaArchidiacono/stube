// The add field: empties after each item and stays focused for the next one.
// Desktop focuses it right away. Phones would pop up the keyboard, so they don't.
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input"]
  static values = { autofocus: Boolean }

  connect() {
    if (this.autofocusValue && window.matchMedia("(min-width: 1024px)").matches) this.inputTarget.focus()
  }

  reset(event) {
    if (!event.detail.success) return
    this.element.reset()
    this.inputTarget.focus()
  }
}
