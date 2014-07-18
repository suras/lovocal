class ListingCategory
  include Mongoid::Document
  include Mongoid::Tree
  include Mongoid::Tree::Ordering
  # include Mongoid::Tree::Traversal
  include Mongoid::Timestamps::Created
  include Mongoid::Timestamps::Updated

  field :name, type: String

  validates :name, presence: true, uniqueness: true

end