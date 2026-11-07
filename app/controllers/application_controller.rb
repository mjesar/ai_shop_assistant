class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes
  rescue_from Mongoid::Errors::DocumentNotFound, with: :chat_not_found

  RATE_LIMIT_MESSAGE = "You are sending messages too quickly. Please wait a moment and try again."

  # New chats and new messages each trigger a paid LLM call, so they share one budget per IP.
  def self.limit_llm_requests(only:, with:)
    rate_limit to: 10, within: 1.minute, name: "minute", scope: "llm", only: only, with: with
    rate_limit to: 100, within: 1.day, name: "day", scope: "llm", only: only, with: with
  end

  private

  def chat_not_found
    redirect_to chats_path, alert: "That chat no longer exists."
  end

  def visitor_chats
    Chat.where(owner_token: visitor_token)
  end

  # There are no accounts, so an encrypted cookie identifies the visitor. It outlives the
  # browser session so that closing the browser does not lose the visitor's chats.
  def visitor_token
    @visitor_token ||= cookies.encrypted[:visitor_token] || SecureRandom.uuid.tap do |token|
      cookies.encrypted[:visitor_token] = {
        value: token, expires: 1.year, httponly: true, same_site: :lax, secure: request.ssl?
      }
    end
  end
end
