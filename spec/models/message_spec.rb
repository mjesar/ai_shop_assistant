require 'rails_helper'

RSpec.describe Message, type: :model do
  it 'is invalid without a role' do
    chat = Chat.create!(model_id: 'gemini-3.6-flash')
    message = Message.new(chat: chat, role: nil, content: 'Hello')
    expect(message).not_to be_valid
  end

  it 'is invalid without content' do
    chat = Chat.create!(model_id: 'gemini-3.6-flash')
    message = Message.new(chat: chat, role: 'user', content: nil)
    expect(message).not_to be_valid
  end
end
