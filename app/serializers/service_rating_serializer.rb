class ServiceRatingSerializer < ActiveModel::Serializer
  attributes :id, :comment, :rating, :user_id, :service_id

  def id
  	object.id.to_s
  end

  def user_id
  	object.user_id.to_s
  end

  def service_id
    object.service_id.to_s
  end

end
