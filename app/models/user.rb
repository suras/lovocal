class User
  include Mongoid::Document
  include Mongoid::Timestamps::Created
  include Mongoid::Timestamps::Updated
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  ## Database authenticatable
  field :email,                      type: String
  field :first_name,                 type: String
  field :last_name,                  type: String
  field :description,                type: String
  field :mobile_number,              type: String, default: ""
  field :encrypted_phone_id,         type: String, default: ""
  field :auth_token,                 type: String
  field :is_verified_by_sms,         type: Boolean, default: false
  field :sms_serial_key,             type: String, default: ""
  field :sms_serial_key_sent_at,     type: DateTime, default: ""
  field :restrict_sms_sent_time,     type: DateTime, default: ""
  field :total_sms_sent,             type: Integer, default: 0
  field :restrict_sms_count,         type: Integer, default: 0
  field :encrypted_password,         type: String, default: ""

  ## Recoverable
  # field :reset_password_token,   type: String
  # field :reset_password_sent_at, type: Time

  ## Rememberable
   field :remember_created_at, type: Time

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
  
  before_save :ensure_authentication_token, :mobile_verification_serial
  before_validation :ensure_password

  has_many :services
  has_many :chat_logs
  has_many :user_chat_logs
  has_many :service_ratings
  has_many :chat_queries
  has_many :chats
  
  validates :mobile_number, presence: true,
                      numericality: true,
                      uniqueness: true,
                      length: { minimum: 10, maximum: 15 }
  validates :email, uniqueness: true, allow_blank: true, allow_nil: true
  validates :encrypted_phone_id, uniqueness: true, allow_blank: true, allow_nil: true
  mount_uploader :image, ProfileImageUploader
  
  def ensure_authentication_token
    if auth_token.blank?
      self.auth_token = generate_authentication_token
    end
  end

  def mobile_verification_serial
    if sms_serial_key.blank?
      self.sms_serial_key = SecureRandom.random_number(88888888)
    end
  end

  def ensure_password
    return if self.password.present?
    self.password = SecureRandom.random_number(8888888888)
  end

  def image_url
    Rails.application.secrets.app_url+self.image.url
  end

  # for devise remove email validation
  def email_required?
    false
  end

  # for devise remove email validation
  def email_changed?
    false
  end

  def chatted_services
    chat_logs = self.user_chat_logs
    services = Array.new
    chat_logs.each do |c|
      services << c.service
    end
    return services
  end

  def name
    self.first_name
  end

  def send_sms_key
    can_send_sms = sms_limit_check
    raise "No more sms now" unless can_send_sms
    account_sid = Rails.application.secrets.twilio_account_sid
    auth_token = Rails.application.secrets.twilio_auth_token
    client = Twilio::REST::Client.new account_sid, auth_token
    ss = client.account.messages.create(
        :from => '(847) 380-8587',
        :to => '+919900431166',
        :body => self.sms_serial_key
     )
    self.sms_serial_key_sent_at = Time.now
    self.restrict_sms_sent_time = Time.now + 60.minutes
    self.total_sms_sent = self.total_sms_sent += 1
    self.restrict_sms_count = self.restrict_sms_count += 1
    self.save
  end

  def sms_limit_check
   return true unless self.restrict_sms_sent_time
    if(self.restrict_sms_sent_time < Time.now  && self.restrict_sms_count < 3)
     true
    else
    false
    end
  end

  def online?
    updated_at > 10.minutes.ago
  end

  # for mongoid $oid issue with session serialization
  def self.serialize_from_session(key, salt)
    record = to_adapter.get(key[0]['$oid'])
    record if record && record.authenticatable_salt == salt
  end

  private
    def generate_authentication_token
      loop do
        token = Devise.friendly_token
        break token unless User.where(auth_token: token).first
      end
    end
end
