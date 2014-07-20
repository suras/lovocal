class ChatResponseLog
  include Mongoid::Document
  include Mongoid::Timestamps::Created
  include Mongoid::Timestamps::Updated

  field :responded, type: Boolean, default: false
  field :chat_id, type: Boolean, default: false
  
  belongs_to :service
end
