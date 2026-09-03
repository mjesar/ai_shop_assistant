class MessagesController < ApplicationController
  def create
    @chat = Chat.find(params[:chat_id])
    @chat.messages.create!(role: 'user', content: params[:content])
    ChatResponseJob.perform_later(@chat.id, params[:content])
    head :no_content
  rescue Mongoid::Errors::Validations => e
    render turbo_stream: turbo_stream.append(
      :messages, partial: "messages/error",
      locals: { error_message: e.document.errors.full_messages.to_sentence }
    ), status: :unprocessable_entity
  end
end
