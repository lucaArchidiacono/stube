// Sorting the list by hand. Drag on desktop, long-press then drag on touch.
// The new position goes to the server, which tells the other devices.
import { Controller } from "@hotwired/stimulus"
import Sortable from "sortablejs"

export default class extends Controller {
  connect() {
    this.sortable = Sortable.create(this.element, {
      animation: 150,
      delay: 300,
      delayOnTouchOnly: true,
      filter: "button, input",
      preventOnFilter: false,
      ghostClass: "opacity-40",
      onEnd: (event) => this.save(event)
    })
  }

  disconnect() {
    this.sortable.destroy()
  }

  save({ item, oldIndex, newIndex }) {
    if (oldIndex === newIndex) return

    const body = new FormData()
    body.append("position", newIndex)
    fetch(item.dataset.positionUrl, {
      method: "PATCH",
      body,
      headers: {
        "X-CSRF-Token": document.querySelector("meta[name=csrf-token]").content,
        Accept: "text/vnd.turbo-stream.html"
      }
    })
  }
}
