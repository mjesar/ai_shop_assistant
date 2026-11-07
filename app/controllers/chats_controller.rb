class ChatsController < ApplicationController
  limit_llm_requests only: :create, with: :too_many_new_chats

  def index
    @chats = visitor_chats
  end

  def new
  end

  def show
    @chat = visitor_chats.find(params[:id])
  end

  def create
    @chat = Chat.start!(model_id: "gemini-3.5-flash-lite", content: params[:content], owner_token: visitor_token)
    redirect_to @chat
  end

  def destroy
    @chat = visitor_chats.find(params[:id])
    @chat.destroy
    redirect_to chats_path, notice: "Chat deleted."
  end

  private

  def too_many_new_chats
    flash.now[:alert] = RATE_LIMIT_MESSAGE
    render :new, status: :too_many_requests
  end
end
