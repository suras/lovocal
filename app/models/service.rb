class Service
  include Mongoid::Document
  include Mongoid::Timestamps::Created
  include Mongoid::Timestamps::Updated
  
  field :business_name,               type: String, default: ""
  field :mobile_number,               type: String, default: ""
  field :landline_number,             type: String
  field :email,                       type: String
  field :description,                 type: String, default: ""
  field :customer_care_number,        type: Array
  field :latitude,                    type: String, default: ""
  field :longitude,                   type: String, default: ""
  field :location,                    type: Array
  field :country,                     type: String
  field :state,                       type: String
  field :city,                        type: String
  field :address,                     type: String
  field :zip_code,                    type: String
  field :website,                     type: String
  field :facebook_link,               type: String
  field :twitter_link,                type: String
  field :linkedin_link,               type: String
  field :list_cat_ids,                type: Array
  field :verified_by_sms,             type: Boolean, default: false

  index({ location: "2d" }, { min: -200, max: 200 })

  before_save :update_geo_location

  belongs_to  :listing
  belongs_to  :user
  embeds_many :service_images
  embeds_one :service_timing

  validates :business_name, :description, :latitude, :longitude,
            :city, :country, :address, presence: true
  validates :mobile_number, presence: true,
             numericality: true,
             length: { minimum: 10, maximum: 15 }
  validates :latitude , numericality: { greater_than:  -90, less_than:  90 }
  validates :longitude, numericality: { greater_than: -180, less_than: 180 }

  accepts_nested_attributes_for :service_images

  def update_geo_location
    if latitude.present? && longitude.present?
      location = [latitude, longitude]
    end
  end 


end

