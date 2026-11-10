// Copies a link. Browsers only allow it over HTTPS or on localhost, so on a
// plain-HTTP home server the button stays hidden and the link can be selected.
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["source", "button"]

  connect() {
    this.buttonTarget.hidden = !navigator.clipboard
  }

  select() {
    this.sourceTarget.select()
  }

  async copy() {
    await navigator.clipboard.writeText(this.sourceTarget.value)
    this.buttonTarget.textContent = "Copied"
  }
}
