class MessagesController < ApplicationController
  limit_llm_requests only: :create, with: :too_many_messages

  def create
    @chat = visitor_chats.find(params[:chat_id])
    @chat.messages.create!(role: "user", content: params[:content])
    ChatResponseJob.perform_later(@chat.id, params[:content])
    head :no_content
  rescue Mongoid::Errors::Validations => e
    render_error(e.document.errors.full_messages.to_sentence, :unprocessable_entity)
  end

  private

  def too_many_messages
    render_error(RATE_LIMIT_MESSAGE, :too_many_requests)
  end

  def render_error(message, status)
    render turbo_stream: turbo_stream.append(
      :messages, partial: "messages/error", locals: { error_message: message }
    ), status: status
  end
end
