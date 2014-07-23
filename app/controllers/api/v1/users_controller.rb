class Api::V1::UsersController < Api::V1::BaseController
  before_action :authenticate_user!, except: [:show, :create, :verify_sms_key, :get_key]
  # GET /user_profile
  def current_user_profile
    @user  = current_user
    render json: @user
  rescue => e
    render json: {error_code: Code[:error_rescue], error_message: e.message}, status: Code[:status_error]
  end

  # GET '/users/id'
  def show
    @user  = User.find(params[:id])
    render json: @user, serializer: UserProfileSerializer, root: "user"
  rescue => e
     render json: {error_code: Code[:error_rescue], error_message: e.message}, status: Code[:status_error]
  end

  # POST '/users'
  def create
    @user = User.where(mobile_number: params[:user][:mobile_number]).first
    if(@user.present?)
      existing_user
    else
      create_new_user
    end
  rescue => e
     render json: {error_code: Code[:error_rescue], error_message: e.message}, status: Code[:status_error]
  end
  
  def existing_user
    if(@user.update_attributes(sms_serial_key: ""))
      render json: @user
    else
      render json: {error_code: Code[:error_rescue], error_message: @user.errors.full_messages}, status: Code[:status_error]  
    end
  end

  def create_new_user
    @user = User.new(user_create_params)
    if(@user.save)
      render json: @user
    else
      render json: {error_code: Code[:error_rescue], error_message: @user.errors.full_messages}, status: Code[:status_error]
    end
  end
 
  # POST /verify_sms_key 
  def verify_sms_key
    @user = User.where(mobile_number: params[:user][:mobile_number], sms_serial_key: params[:user][:sms_serial_key]).first
    if(@user.present?)
      @user.is_verified_by_sms = true
      @user.auth_token = ""
      @user.encrypted_phone_id = params[:user][:phone_id]
      @user.save
      render json: @user, serializer: UserAuthSerializer, root: "user"
    else
      render json: {auth_token: ""}, status: Code[:status_error]
    end
  end

  # POST '/login'
  def login
    @user = User.where(mobile_number: params[:user][:mobile_number], sms_serial_key: params[:user][:sms_serial_key])
    if(@user.present?)  
      render json: @user
    else
      render json: {error_code: Code[:error_rescue], error_message: "User Not Present"}, status: Code[:status_error]
    end
  end

  # PUT/PATCH '/users/id'
  def update
    @user  = current_user
    if(params[:image].present?)
      @user.image = params[:image]
    end
    if(@user.update_attributes(user_params))
      render json: @user
    else
      render json: {error_code: Code[:error_resource], error_message: @user.errors.full_messages},  status: Code[:status_error]
    end
  rescue => e
     render json: {error_code: Code[:error_rescue], error_message: e.message}, status: Code[:status_error]
  end

  # DELETE /users/1.json
  def destroy
    current_user.destroy
    render json: { head: :no_content }
  rescue => e
    render json: {error_code: Code[:error_rescue], error_message: e.message}, status: Code[:status_error]
  end

  # GET /users/current_user_services
  def current_user_services
    @services = current_user.services
    render json: @services, root: :services
  rescue => e
     render json: {error_code: Code[:error_rescue], error_message: e.message}, status: Code[:status_error]    
  end

  # GET /users/:user_id/services
  def user_services
    @user = User.find(params[:user_id])
    @services = @user.services
    render json: @services, root: :services
  rescue => e
     render json: {error_code: Code[:error_rescue], error_message: e.message}, status: Code[:status_error]    
  end
 
 # GET /key
  def get_key
    user = User.where(mobile_number: params[:mobile_number]).first
    render json: user.to_json
  end

  private
    # Never trust parameters from the scary internet, only allow the white list through.
    def user_params
      params.require(:user).permit(:first_name, :last_name, :mobile_number, :email, 
        :image, :description)
    end

    def user_create_params
      params.require(:user).permit(:mobile_number)
    end
end
