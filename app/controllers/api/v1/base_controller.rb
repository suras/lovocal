class Api::V1::BaseController < ActionController::API
  # skip_before_filter :verify_authenticity_token, :if => Proc.new { |c| c.request.format == 'application/json' }
  skip_before_action :verify_authenticity_token
  include ActionController::MimeResponds
  include ActionController::Cookies
  include ActionController::HttpAuthentication::Token
  before_action :authenticate_user_from_token!

  private
    def authenticate_user_from_token!
      request.format = "json"
      user_token = token_and_options(request).presence
      return if user_token.blank?
      user_phone_id = user_token[1][:phone_id].presence 
      user = user_phone_id && User.where(encrypted_phone_id: user_phone_id).first
      if user && Devise.secure_compare(user.auth_token, user_token[0])
        sign_in user, store: false
      end
    end
end
