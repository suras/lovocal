class UserSerializer < ActiveModel::Serializer
  attributes :id, :mobile_number, :first_name, :last_name, :email,
             :image_url, :description, :mobile_number, :share_token 

  def image_url
    object.image_url
  end

  def id
  	object.id.to_s
  end

end
