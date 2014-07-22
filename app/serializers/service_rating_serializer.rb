class ServiceRatingSerializer < ActiveModel::Serializer
  attributes :id, :name, :rating

  def id
  	object.id.to_s
  end

end
