class Chat
include Mongoid::Document
include Mongoid::Timestamps

field :model_id, type: String

has_many :messages, depen
end
