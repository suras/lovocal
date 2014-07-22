class ServiceChatBlock
  include Mongoid::Document
  include Mongoid::Timestamps::Created
  include Mongoid::Timestamps::Updated

  field :service_id, type: String
  field :user_id, type: String
end
