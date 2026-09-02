require 'rails_helper'

RSpec.describe "Messages", type: :request do
  describe "POST /chats/:chat_id/messages" do
    it "saves the user message and enqueues a background job" do
      chat = Chat.create!(model_id: 'gemini-3.6-flash')

      expect {
        post "/chats/#{chat.id}/messages", params: { content: 'Hi' }
      }.to have_enqueued_job(ChatResponseJob).with(chat.id.to_s, 'Hi')

      expect(response).to have_http_status(:no_content)
      expect(chat.messages.count).to eq(1)
      expect(chat.messages.first.content).to eq('Hi')
    end
  end
end
