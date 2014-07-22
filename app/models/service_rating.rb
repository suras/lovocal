class ServiceRating
  include Mongoid::Document
  include Mongoid::Timestamps::Created
  include Mongoid::Timestamps::Updated

  field :comment, type: String
  field :rating, type: Integer, default: 0
  field :service_id, type: BSON::ObjectId
  field :user_id, type: BSON::ObjectId

  before_save :cast_integer_type_for_rating
  after_save  :update_service_rating
  
  belongs_to :user
  belongs_to :service


  # validates :rating, format: {with: /[1,2,3,4,5]{0,1}/}, 
  #                    message: "the rating can be only numbers 1 to 5"
   validates :rating, inclusion: { in: [1,2,3,4,5],
    message:"can contain only numbers between 1 to 5" }, allow_blank: true, allow_nil: true
   validate :comment_or_rating_should_be_present


   def comment_or_rating_should_be_present
     if comment.blank? && rating.blank?
     	errors.add(:base, "either rating or comment should be present")
     end
   end

   def cast_integer_type_for_rating
   	  self.rating = rating.to_i
   end

   def update_service_rating
     service = self.service
     service.update_avg_rating
   end

end
