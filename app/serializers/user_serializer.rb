class UserSerializer < ActiveModel::Serializer
  attributes :id, :mobile_number, :first_name, :last_name, :auth_token, :email,
             :image_url, :description, :mobile_number

  def image_url
    object.image
  end

  def id
  	object.id.to_s
  end

end
