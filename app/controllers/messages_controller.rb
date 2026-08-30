class MessagesController < ApplicationController
  def create
    @chat = Chat.find(params[:chat_id])
    @chat.ask(params[:content])
    redirect_to @chat
  end
end
