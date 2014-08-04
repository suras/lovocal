class UserAuthSerializer < ActiveModel::Serializer
  attributes :id, :mobile_number, :first_name, :last_name, :auth_token, :email,
             :image_url, :description, :mobile_number, :share_token 


  def image_url
    object.image_url
  end

  def id
  	object.id.to_s
  end

  def auth_token
  	if(object.is_verified_by_sms?)
      object.auth_token
    else
      ""
    end
  end

end
