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
    response = RubyLLM.chat(model: model_id).with_tool(SearchProducts).ask(content)
    messages.create!(role: 'assistant', content: response.content)
    response
  end
end
