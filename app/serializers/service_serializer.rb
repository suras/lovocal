class ServiceSerializer < ActiveModel::Serializer
  attributes :id, :business_name, :mobile_number, :listing_categories, :latitude,
             :longitude, :country, :city, :state, :zip_code, :description, 
             :customer_care_number, :landline_number, :address, :website,
             :twitter_link, :facebook_link, :linkedin_link, :list_cat_ids,
             :rating
  has_many :service_images
  has_one :service_timing

  def id
  	object.id.to_s
  end

  def listing_categories
    listing_categories = ListingCategory.find(object.list_cat_ids).map{
    	|cat| cat.name
    }
  end

end
