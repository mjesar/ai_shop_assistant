require 'rails_helper'

RSpec.describe "Messages", type: :request do
  describe "POST /chats/:chat_id/messages" do
    it "sends a message and redirects to the chat" do
      chat = Chat.create!(model_id: 'gemini-3.6-flash')

      fake_response = double(content: 'Hello there!')
      fake_llm_chat = double('RubyLLM::Chat')
      allow(fake_llm_chat).to receive(:with_tool).and_return(fake_llm_chat)
      allow(fake_llm_chat).to receive(:ask).and_return(fake_response)
      allow(RubyLLM).to receive(:chat).and_return(fake_llm_chat)

      post "/chats/#{chat.id}/messages", params: { content: 'Hi' }

      expect(response).to redirect_to(chat_path(chat))
      expect(chat.messages.count).to eq(2)
    end
  end
end
