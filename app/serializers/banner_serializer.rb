class BannerSerializer < ActiveModel::Serializer
  attributes :image_url


  def image_url
    object.image_url
  end

end
