import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="chat"
export default class extends Controller {
  static targets = ["input", "button", "messages"]

  connect() {
    this.thinking = false
    this.observer = new MutationObserver(this.handleNewMessage.bind(this))
    this.observer.observe(this.messagesTarget, { childList: true })
  }

  disconnect() {
    this.observer.disconnect()
  }

  submit(event) {
    if (this.thinking) {
      event.preventDefault()
      return
    }

    this.thinking = true
    this.inputTarget.value = ""
    this.inputTarget.disabled = true
    this.buttonTarget.disabled = true
    this.buttonTarget.value = "Thinking..."
  }

  // Turbo re-enables the submitter as soon as the POST /messages request
  // completes, long before the assistant's reply actually arrives. Re-assert
  // our own disabled state afterward rather than fighting Turbo's default.
  submitEnd(event) {
    if (!this.thinking) return

    if (event.detail.success) {
      this.inputTarget.disabled = true
      this.buttonTarget.disabled = true
      this.buttonTarget.value = "Thinking..."
    } else {
      this.thinking = false
      this.inputTarget.disabled = false
      this.buttonTarget.disabled = false
      this.buttonTarget.value = "Send"
    }
  }

  handleNewMessage(mutations) {
    const selector = '[data-role="assistant"], [data-role="error"]'
    for (const mutation of mutations) {
      for (const node of mutation.addedNodes) {
        if (node.nodeType !== 1) continue
        const isReply = node.matches?.(selector) || node.querySelector?.(selector)
        if (isReply) {
          this.thinking = false
          this.inputTarget.disabled = false
          this.buttonTarget.disabled = false
          this.buttonTarget.value = "Send"
        }
      }
    }
  }
}
