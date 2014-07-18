class UserProfileSerializer < ActiveModel::Serializer
  attributes  :id, :mobile_number, :first_name, :last_name, :image_url

  def image_url
    object.image
  end

  def id
  	object.id.to_s
  end

end
