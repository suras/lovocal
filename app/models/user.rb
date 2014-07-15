class User
  include Mongoid::Document
  include Mongoid::Timestamps::Created
  include Mongoid::Timestamps::Updated
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  ## Database authenticatable
  field :email,               type: String, default: ""
  field :first_name,          type: String
  field :last_name,           type: String
  field :description,         type: String
  field :mobile_number,       type: String, default: ""
  field :image,               type: String
  field :encrypted_phone_id,  type: String
  field :auth_token,          type: String
  # field :encrypted_password, type: String, default: ""

  ## Recoverable
  # field :reset_password_token,   type: String
  # field :reset_password_sent_at, type: Time

  ## Rememberable
  # field :remember_created_at, type: Time

  ## Trackable
  field :sign_in_count,      type: Integer, default: 0
  field :current_sign_in_at, type: Time
  field :last_sign_in_at,    type: Time
  field :current_sign_in_ip, type: String
  field :last_sign_in_ip,    type: String

  ## Confirmable
  # field :confirmation_token,   type: String
  # field :confirmed_at,         type: Time
  # field :confirmation_sent_at, type: Time
  # field :unconfirmed_email,    type: String # Only if using reconfirmable

  ## Lockable
  # field :failed_attempts, type: Integer, default: 0 # Only if lock strategy is :failed_attempts
  # field :unlock_token,    type: String # Only if unlock strategy is :email or :both
  # field :locked_at,       type: Time
  mount_uploader :image, ProfileImageUploader

  before_save :ensure_authentication_token
  
  validates :mobile_number, :presence => {:message => 'Phone Number Not Valid'},
                     :numericality => true,
                     :length => { :minimum => 10, :maximum => 15 }
  
  def ensure_authentication_token
    if auth_token.blank?
      self.auth_token = generate_authentication_token
    end
  end

  private
    def generate_authentication_token
      loop do
        token = Devise.friendly_token
        break token unless User.where(auth_token: token).first
      end
    end
end
