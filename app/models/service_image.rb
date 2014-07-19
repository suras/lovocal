class ServiceImage
  include Mongoid::Document
  include Mongoid::Timestamps::Created
  include Mongoid::Timestamps::Updated

  field :image,          type: String
  field :is_main,        type: Boolean, default: false

  embedded_in :service

  mount_uploader :image, ProfileImageUploader

end
