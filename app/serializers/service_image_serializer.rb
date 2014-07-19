class ServiceImageSerializer < ActiveModel::Serializer
  attributes :id, :image_url, :is_main
  
  def id
  	object.id.to_s
  end

  def image_url
    Rails.application.secrets.app_url+object.image.url
  end
  
end
