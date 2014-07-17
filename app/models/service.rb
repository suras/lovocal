class Service
  include Mongoid::Document
  include Mongoid::Timestamps::Created
  include Mongoid::Timestamps::Updated
  
  field :business_name,              type: String, default: ""
  field :mobile_number,              type: String, default: ""
  field :landline_number             type: String
  field :email,                      type: String
  field :description                 type: String, default: ""
  field :custome_care_no             type: Array
  field :latitude                    type: String
  field :longitude                   type: String
  field :country                     type: String
  field :State                       type: String
  field :city                        type: String
  field :zip_code                    type: String
  field :website                     type: String
  field :facebook_link               type: String
  field :twitter_link                type: String
  field :linkedin_link               type: String
  field :verified_by_sms             type: Boolean, default: false

  belongs_to  :listing
  belongs_to  :listing_category
  embeds_many :service_images
  embeds_many :service_timings

  validates :business_name, :description, :latitude, :longitude,
            :city, presence: true
  validates :mobile_number, presence: true,
             numericality: true,
             length: { minimum: 10, maximum: 15 }
end

