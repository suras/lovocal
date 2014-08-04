class UserShare
  include Mongoid::Document
  
  field :referral_id, type: String
  field :device_id, type: String

  belongs_to :user


end
