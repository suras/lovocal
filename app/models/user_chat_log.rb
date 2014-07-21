class UserChatLog
  include Mongoid::Document
  include Mongoid::Timestamps::Created
  include Mongoid::Timestamps::Updated

  field :service_id, type: String
  field :list_cat_id, type: String

  belongs_to :user

end
