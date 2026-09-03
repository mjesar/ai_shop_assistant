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
    it "creates a new chat with its first message and redirects to it" do
      expect {
        post "/chats", params: { content: 'Hi' }
      }.to change(Chat, :count).by(1)
        .and have_enqueued_job(ChatResponseJob)

      expect(response).to redirect_to(chat_path(Chat.last))
      expect(Chat.last.messages.first.content).to eq('Hi')
    end
  end
end
