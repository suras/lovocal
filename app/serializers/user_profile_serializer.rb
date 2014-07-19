class UserProfileSerializer < ActiveModel::Serializer
  attributes  :id, :mobile_number, :first_name, :last_name, :image_url

  def image_url
    Rails.application.secrets.app_url+object.image.url
  end

  def id
  	object.id.to_s
  end

end
