class Message
  include Mongoid::Document
  include Mongoid::Timestamps

  field :role, type: String
  field :content, type: String

  belongs_to :chat

  validates :role, presence: true
  validates :content, presence: true
end
