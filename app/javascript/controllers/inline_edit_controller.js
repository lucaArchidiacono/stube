// Tap an item's text to edit it in place. Enter saves, Esc cancels, tapping
// elsewhere saves if something changed. Delete shows next to the field.
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["text", "form", "input", "delete"]

  edit() {
    this.toggle(true)
    this.inputTarget.value = this.textTarget.textContent.trim()
    this.inputTarget.focus()
    this.inputTarget.select()
  }

  cancel() {
    this.toggle(false)
  }

  // Every save goes through here, from Enter or from blur. Shows the new name
  // right away, and an empty or unchanged name just cancels.
  submit(event) {
    const name = this.inputTarget.value.trim()
    if (!name || name === this.textTarget.textContent.trim()) {
      event.preventDefault()
    } else {
      this.textTarget.textContent = name
    }
    this.toggle(false)
  }

  // Wait a moment: the blur may come from tapping Delete, which must win.
  blur() {
    setTimeout(() => {
      if (!this.element.isConnected || this.isDeleting || this.formTarget.hidden) return
      this.formTarget.requestSubmit()
    }, 150)
  }

  deleting() {
    this.isDeleting = true
  }

  toggle(editing) {
    this.textTarget.hidden = editing
    this.formTarget.hidden = !editing
    this.deleteTarget.hidden = !editing
  }
}
