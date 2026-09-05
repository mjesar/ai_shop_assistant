require 'rails_helper'

RSpec.describe Chat, type: :model do
  it 'is valid with a model_id' do
    chat = Chat.new(model_id: 'gemini-2.0-flash')
    expect(chat).to be_valid
  end

  describe '#ask' do
    it 'saves the user message before calling the AI' do
      chat = Chat.create!(model_id: 'gemini-2.0-flash')

      fake_response = double(content: 'Hello there!')
      fake_llm_chat = double('RubyLLM::Chat')
      allow(fake_llm_chat).to receive(:with_tool).and_return(fake_llm_chat)
      allow(fake_llm_chat).to receive(:on_tool_call).and_return(fake_llm_chat)
      allow(fake_llm_chat).to receive(:ask).and_return(fake_response)
      allow(RubyLLM).to receive(:chat).and_return(fake_llm_chat)

      chat.ask('Hi')

      expect(chat.messages.first.role).to eq('user')
      expect(chat.messages.first.content).to eq('Hi')
    end

    it 'replays prior conversation turns into the LLM chat on the next ask' do
      chat = Chat.create!(model_id: 'gemini-2.0-flash')

      first_llm_chat = double('RubyLLM::Chat (turn 1)')
      allow(first_llm_chat).to receive(:with_tool).and_return(first_llm_chat)
      allow(first_llm_chat).to receive(:on_tool_call)
      allow(first_llm_chat).to receive(:add_message)
      allow(first_llm_chat).to receive(:ask).and_return(double(content: 'Nice to meet you, Alex!'))

      second_llm_chat = double('RubyLLM::Chat (turn 2)')
      allow(second_llm_chat).to receive(:with_tool).and_return(second_llm_chat)
      allow(second_llm_chat).to receive(:on_tool_call)
      replayed_messages = []
      allow(second_llm_chat).to receive(:add_message) { |attrs| replayed_messages << attrs }
      allow(second_llm_chat).to receive(:ask).and_return(double(content: 'Your name is Alex.'))

      allow(RubyLLM).to receive(:chat).and_return(first_llm_chat, second_llm_chat)

      chat.ask('My name is Alex')
      expect(first_llm_chat).not_to have_received(:add_message)

      chat.ask('What is my name?')

      expect(replayed_messages).to eq([
        { role: :user, content: 'My name is Alex' },
        { role: :assistant, content: 'Nice to meet you, Alex!' }
      ])
    end
  end
  describe '.start!' do
    it 'creates a chat and its first message, then enqueues a background job for the reply' do
      chat = nil

      expect {
        chat = Chat.start!(model_id: 'gemini-3.5-flash-lite', content: 'Hi')
      }.to have_enqueued_job(ChatResponseJob)

      expect(chat.persisted?).to be true
      expect(chat.messages.count).to eq(1)
      expect(chat.messages.first.role).to eq('user')
      expect(chat.messages.first.content).to eq('Hi')
    end
  end
end
