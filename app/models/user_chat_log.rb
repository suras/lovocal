class UserChatLog
  include Mongoid::Document
  include Mongoid::Timestamps::Created
  include Mongoid::Timestamps::Updated

  field :service_id, type: String
  field :list_cat_id, type: String
  field :send_status, type: Boolean, default: true

  belongs_to :user

  def service
    Service.where(_id: self.service_id).first
  end

end
