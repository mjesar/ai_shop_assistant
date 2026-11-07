require 'rails_helper'

RSpec.describe "Chats", type: :request do
  def start_own_chat
    post "/chats", params: { content: 'Hi' }
    Chat.last
  end

  let(:someone_elses_chat) { Chat.create!(model_id: 'someone-elses-model', owner_token: 'another-visitor') }
  let(:ownerless_chat) { Chat.create!(model_id: 'ownerless-model') }

  describe "GET /chats" do
    it "returns http success" do
      get "/chats"
      expect(response).to have_http_status(:success)
    end

    it "lists only the visitor's own chats" do
      someone_elses_chat
      ownerless_chat
      start_own_chat

      get "/chats"

      expect(response.body).to include('gemini-3.5-flash-lite')
      expect(response.body).not_to include('someone-elses-model')
      expect(response.body).not_to include('ownerless-model')
    end
  end

  describe "GET /chats/:id" do
    it "shows the visitor's own chat" do
      chat = start_own_chat
      get "/chats/#{chat.id}"
      expect(response).to have_http_status(:success)
    end

    it "does not show another visitor's chat and displays why" do
      get "/chats/#{someone_elses_chat.id}"
      expect(response).to redirect_to(chats_path)

      follow_redirect!
      expect(response.body).to include('That chat no longer exists.')
    end

    it "does not show a chat that has no owner" do
      get "/chats/#{ownerless_chat.id}"
      expect(response).to redirect_to(chats_path)
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

    it "gives the visitor an http-only cookie that lasts beyond the session" do
      post "/chats", params: { content: 'Hi' }

      cookie = response.headers['Set-Cookie'].to_s.split("\n").find { |c| c.start_with?('visitor_token=') }
      expect(cookie).to match(/httponly/i)
      expect(cookie).to match(/samesite=lax/i)
      expect(cookie).to match(/expires=/i)
    end

    it "refuses to start a chat once the visitor is over the rate limit" do
      allow(ChatsController.cache_store).to receive(:increment).and_return(11)

      expect {
        post "/chats", params: { content: 'Hi' }
      }.not_to change(Chat, :count)

      expect(response).to have_http_status(:too_many_requests)
      expect(response.body).to include('too quickly')
      expect(ChatResponseJob).not_to have_been_enqueued
    end
  end

  describe "DELETE /chats/:id" do
    it "deletes the visitor's own chat and confirms it" do
      chat = start_own_chat

      expect { delete "/chats/#{chat.id}" }.to change(Chat, :count).by(-1)

      follow_redirect!
      expect(response.body).to include('Chat deleted.')
    end

    it "does not delete another visitor's chat" do
      someone_elses_chat

      expect { delete "/chats/#{someone_elses_chat.id}" }.not_to change(Chat, :count)
      expect(response).to redirect_to(chats_path)
    end
  end
end
