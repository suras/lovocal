class ChatResponseLog
  include Mongoid::Document
  include Mongoid::Timestamps::Created
  include Mongoid::Timestamps::Updated

  field :responded, type: Boolean, default: false
  field :chat_id, type: String
  
  belongs_to :service
end
