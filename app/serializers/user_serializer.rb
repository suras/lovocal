class UserSerializer < ActiveModel::Serializer
  attributes :mobile_number, :first_name, :last_name, :auth_token, :image_url

  def image_url
    object.image
  end

end
