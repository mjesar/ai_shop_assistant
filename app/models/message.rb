class Message
  include Mongoid::Document
  include Mongoid::Timestamps
  include Turbo::Broadcastable

  field :role, type: String
  field :content, type: String

  belongs_to :chat

  validates :role, presence: true
  validates :content, presence: true

  after_create_commit { broadcast_append_to chat, target: 'messages', partial: 'messages/message', locals: { message: self } }

end
