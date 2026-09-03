class ChatResponseJob < ApplicationJob
  queue_as :default

  def perform(chat_id, content)
    Chat.find(chat_id).generate_response(content)
  rescue Mongoid::Errors::DocumentNotFound
    Rails.logger.info "Chat #{chat_id} was deleted before the job could run — skipping."
  end
end
