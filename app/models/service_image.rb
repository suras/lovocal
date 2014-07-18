class ServiceImage
  include Mongoid::Document
  include Mongoid::Timestamps::Created
  include Mongoid::Timestamps::Updated

  field :image, type: String

  embedded_in :service

  # mount_uploader :image, ProfileImageUploader

end
