class ServiceSerializer < ActiveModel::Serializer
  attributes :id, :business_name, :mobile_number, :listing_categories
  has_many :service_images

  def listing_categories
    listing_categories = ListingCategory.find(object.list_cat_ids).map{
    	|cat| cat.name
    }
  end

end
