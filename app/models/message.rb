class Message
  include Mongoid::Document
  include Mongoid::Timestamps

  field :role, type: String
  field :content, type: String

  belongs_to :chat
end
