class Banner
  include Mongoid::Document

  field :image, type: String
  field :priority, type: Integer, default: 0

  mount_uploader :image, ProfileImageUploader
  
  def image_url
    Rails.application.secrets.app_url+self.image.url
  end

end
