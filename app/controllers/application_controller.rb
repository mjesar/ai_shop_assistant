class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes
  rescue_from Mongoid::Errors::DocumentNotFound, with: :chat_not_found

  private

  def chat_not_found
    redirect_to chats_path, alert: "That chat no longer exists."
  end
end
