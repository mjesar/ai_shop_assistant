class ChatsController < ApplicationController
  def index
    @chats = Chat.all
  end

  def show
    @chat = Chat.find(params[:id])
  end

  def create
    @chat = Chat.create!(model_id: 'gemini-3.5-flash-lite')
    redirect_to @chat
  end

  def destroy
    @chat = Chat.find(params[:id])
    @chat.destroy
    redirect_to chats_path, notice: "Chat deleted."
  end
end
