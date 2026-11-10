// Removes itself after a few seconds, like the undo bar.
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { after: { type: Number, default: 5000 } }

  connect() {
    this.timer = setTimeout(() => this.element.remove(), this.afterValue)
  }

  disconnect() {
    clearTimeout(this.timer)
  }
}
