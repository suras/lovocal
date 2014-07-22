class ServiceRatingSerializer < ActiveModel::Serializer
  attributes :id, :comment, :rating, :user_id

  def id
  	object.id.to_s
  end

  def user_id
  	object.id.to_s
  end

end
