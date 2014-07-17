class ListingCategory
  include Mongoid::Document
  include Mongoid::Tree
  include Mongoid::Timestamps::Created
  include Mongoid::Timestamps::Updated

  field :name, type: String

end
