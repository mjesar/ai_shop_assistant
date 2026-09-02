require 'rails_helper'

RSpec.describe ChatResponseJob, type: :job do
  it "calls generate_response on the chat" do
    chat = Chat.create!(model_id: 'gemini-3.6-flash')

    allow(Chat).to receive(:find).with(chat.id).and_return(chat)
    allow(chat).to receive(:generate_response)

    ChatResponseJob.perform_now(chat.id, 'Hello')

    expect(chat).to have_received(:generate_response).with('Hello')
  end
end
