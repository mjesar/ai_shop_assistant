require 'rails_helper'

RSpec.describe "Messages", type: :request do
  def start_own_chat
    post "/chats", params: { content: 'First message' }
    Chat.last
  end

  describe "POST /chats/:chat_id/messages" do
    it "saves the user message and enqueues a background job" do
      chat = start_own_chat

      expect {
        post "/chats/#{chat.id}/messages", params: { content: 'Hi' }
      }.to have_enqueued_job(ChatResponseJob).with(chat.id.to_s, 'Hi')

      expect(response).to have_http_status(:no_content)
      expect(chat.messages.count).to eq(2)
      expect(chat.messages.order_by(created_at: :asc).last.content).to eq('Hi')
    end

    it "does not accept a message for another visitor's chat" do
      chat = Chat.create!(model_id: 'gemini-3.6-flash', owner_token: 'another-visitor')

      expect {
        post "/chats/#{chat.id}/messages", params: { content: 'Hi' }
      }.not_to have_enqueued_job(ChatResponseJob)

      expect(response).to redirect_to(chats_path)
      expect(chat.messages.count).to eq(0)
    end

    it "returns an error stream and queues nothing once over the rate limit" do
      chat = start_own_chat
      allow(MessagesController.cache_store).to receive(:increment).and_return(11)

      expect {
        post "/chats/#{chat.id}/messages", params: { content: 'Hi' }
      }.not_to have_enqueued_job(ChatResponseJob)

      expect(response).to have_http_status(:too_many_requests)
      expect(response.media_type).to eq('text/vnd.turbo-stream.html')
      expect(response.body).to include('too quickly')
      expect(chat.messages.count).to eq(1)
    end
  end
end
