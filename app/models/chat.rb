class Chat
  include Mongoid::Document
  include Mongoid::Timestamps

  field :model_id, type: String

  has_many :messages, dependent: :destroy

  def ask(content)
    messages.create!(role: 'user', content: content)
    generate_response(content)
  end

  def generate_response(content)
    tool_status_shown = false
    llm_chat = RubyLLM.chat(model: model_id).with_tool(SearchProducts)
    llm_chat.on_tool_call do
      unless tool_status_shown
        tool_status_shown = true
        Turbo::StreamsChannel.broadcast_append_to(
          self, target: 'messages', partial: 'messages/tool_status',
          locals: { dom_id: tool_status_dom_id }
        )
      end
    end

    response = llm_chat.ask(content)
    Turbo::StreamsChannel.broadcast_remove_to(self, target: tool_status_dom_id) if tool_status_shown
    messages.create!(role: 'assistant', content: response.content)
    response
  rescue StandardError => e
    Turbo::StreamsChannel.broadcast_remove_to(self, target: tool_status_dom_id) if tool_status_shown
    Turbo::StreamsChannel.broadcast_append_to(
      self, target: 'messages', partial: 'messages/error',
      locals: { error_message: "Sorry, something went wrong generating a response. Please try again." }
    )
    raise
  end

  private

  def tool_status_dom_id
    "tool-status-#{id}"
  end
end
