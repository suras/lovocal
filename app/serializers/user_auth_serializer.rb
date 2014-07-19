class UserAuthSerializer < ActiveModel::Serializer
  attributes :id, :mobile_number, :first_name, :last_name, :auth_token, :email,
             :image_url, :description, :mobile_number

  def image_url
    Rails.application.secrets.app_url+object.image.url
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
