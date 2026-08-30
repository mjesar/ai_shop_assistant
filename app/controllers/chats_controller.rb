class ChatsController < ApplicationController
  def index
    @chats = Chat.all
  end

  def show
    @chat = Chat.find(params[:id])
  end

  def create
    @chat = Chat.create!(model_id: 'gemini-3.6-flash')
    redirect_to @chat
  end
end
