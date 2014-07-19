class ListingCategorySerializer < ActiveModel::Serializer
  attributes :id, :name, :image_url
  
  def id
  	object.id.to_s
  end

  def image_url
    Rails.application.secrets.app_url+object.image.url
  end

end
