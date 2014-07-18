class ServiceImageSerializer < ActiveModel::Serializer
  attributes :id, :image, :is_main
  
  def id
  	object.id.to_s
  end

end
