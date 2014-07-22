class UserChatBlock
  include Mongoid::Document
  include Mongoid::Timestamps::Created
  include Mongoid::Timestamps::Updated

  field :user_id, type: String
  field :service_id, type: String
end
