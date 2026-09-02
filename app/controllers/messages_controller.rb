class MessagesController < ApplicationController
  def create
    @chat = Chat.find(params[:chat_id])
    @chat.messages.create!(role: 'user', content: params[:content])
    ChatResponseJob.perform_later(@chat.id, params[:content])
    head :no_content
  end
end
