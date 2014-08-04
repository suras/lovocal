class ServiceImageSerializer < ActiveModel::Serializer
  attributes :id, :image_url, :is_main
  
  def id
  	object.id.to_s
  end

  def image_url
    object.image_url
  end
  
end
