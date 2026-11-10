// Offline: when the device loses its network, or the live connection to the
// server drops, a bar says so and inputs are disabled. When it's back, the page
// refreshes so it shows what changed in the meantime.
import { Controller } from "@hotwired/stimulus"
import { Turbo, cable } from "@hotwired/turbo-rails"

const CONTROLS = "input, button, textarea, select"
const CHECK_EVERY = 2000

export default class extends Controller {
  static targets = ["bar", "content"]

  async connect() {
    this.offline = false
    this.update = this.update.bind(this)
    window.addEventListener("online", this.update)
    window.addEventListener("offline", this.update)

    this.consumer = await cable.getConsumer()
    this.timer = setInterval(this.update, CHECK_EVERY)
  }

  disconnect() {
    window.removeEventListener("online", this.update)
    window.removeEventListener("offline", this.update)
    clearInterval(this.timer)
  }

  update() {
    const offline = !navigator.onLine || this.liveConnectionLost
    if (offline === this.offline) return

    this.offline = offline
    this.barTarget.hidden = !offline
    this.setControlsDisabled(offline)
    if (!offline) Turbo.visit(window.location.href, { action: "replace" })
  }

  // Lost means the live connection was open once and isn't anymore. A page that
  // is still connecting for the first time isn't offline.
  get liveConnectionLost() {
    const open = this.consumer?.connection.isOpen()
    if (open) this.wasOpen = true
    return Boolean(this.wasOpen && !open)
  }

  // Only re-enables what it disabled itself.
  setControlsDisabled(disabled) {
    this.contentTarget.querySelectorAll(CONTROLS).forEach((control) => {
      if (disabled && !control.disabled) {
        control.disabled = true
        control.dataset.disabledWhileOffline = ""
      } else if (!disabled && "disabledWhileOffline" in control.dataset) {
        control.disabled = false
        delete control.dataset.disabledWhileOffline
      }
    })
  }
}
