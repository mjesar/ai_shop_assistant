class ChatResponseJob < ApplicationJob
  queue_as :default

  def perform(chat_id, content)
    Chat.find(chat_id).generate_response(content)
  end
end
