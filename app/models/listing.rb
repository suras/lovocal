class Listing
  include Mongoid::Document
  include Mongoid::Timestamps::Created
  include Mongoid::Timestamps::Updated
  
  field :listing_type,      type: String, default: ""
  
  has_many :services

end
