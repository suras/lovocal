class ServiceTimingSerializer < ActiveModel::Serializer
  attributes :id, :timings, :holidays

  def id
    object.id.to_s
  end

end
