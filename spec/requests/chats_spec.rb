require 'rails_helper'

RSpec.describe "Chats", type: :request do
  describe "GET /chats" do
    it "returns http success" do
      get "/chats"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /chats/:id" do
    it "returns http success" do
      chat = Chat.create!(model_id: 'gemini-3.6-flash')
      get "/chats/#{chat.id}"
      expect(response).to have_http_status(:success)
    end
  end

  describe "POST /chats" do
    it "creates a new chat and redirects to it" do
      expect {
        post "/chats"
      }.to change(Chat, :count).by(1)

      expect(response).to redirect_to(chat_path(Chat.last))
    end
  end
end
