class UsersController < ApplicationController
  before_action :authenticate_user!, except: [:show, :new, :new_login, 
    :create, :verify_sms_key, :get_key, :create_password, :create_login]
 
  # GET /user_profile
  def current_user_profile
    @user  = current_user
    render json: @user
  end

  # GET '/users/id'
  def show
    @user  = User.find(params[:id])
    render json: @user, serializer: UserProfileSerializer, root: "user"
  end

  # GET /users/new
  def new
    @user = User.new
  end

  # POST '/users'
  def create
    @user = User.where(mobile_number: params[:user][:mobile_number]).first
    if(@user.present?)
      existing_user
    else
      create_new_user
    end
  end
  
  def existing_user
    respond_to do |format|
      if(@user.update_attributes(sms_serial_key: ""))
        @user.sms_serial_key = ""
        @user.password = ""
        # @user.send_sms_key
        format.js {render "create"}
      else
        format.js { render "create" }
      end
    end
  end

  def create_new_user
    @user = User.new(user_create_params)
    respond_to do |format|
      if(@user.save)
        # @user.send_sms_key
         @user.sms_serial_key = ""
         @user.password = ""
        format.js {render "create"}
      else
        format.js { render "create" }
      end
    end
  end
  
  # GET /users/login/new
  def new_login

  end

  # POST /users/login/ 
  def create_login
    @user = User.where(mobile_number: params[:mobile_number]).first
    respond_to do |format|
      if(@user && @user.valid_password?(params[:password]))
        sign_in @user, store: true
        format.html { redirect_to root_url, notice: 'Signed In Successfully' }
      else
        format.html { redirect_to new_user_login_path, notice: 'Invalid Login Details' }
      end
    end
  end

  # POST /users/create_password
  def create_password
    @user = User.where(mobile_number: params[:user][:mobile_number], sms_serial_key: params[:user][:sms_serial_key]).first
    respond_to do |format|
      if(@user.present?)
        @user.is_verified_by_sms = true
        @user.restrict_sms_count = 0
        @user.first_name = params[:user][:first_name]
        @user.first_name = params[:user][:last_name]
        @user.password = params[:user][:password]
        @user.save
        sign_in @user, store: true
        format.html { redirect_to root_url, notice: 'Signed Up Successfully' }
      else
        @user = User.new
        format.html { render partial: "create_new_password" }
      end
    end 
  end

  # POST /verify_sms_key 
  def verify_sms_key
    @user = User.where(mobile_number: params[:user][:mobile_number], sms_serial_key: params[:user][:sms_serial_key]).first
    if(@user.present?)
      @user.is_verified_by_sms = true
      @user.auth_token = ""
      @user.encrypted_phone_id = params[:user][:phone_id]
      @user.restrict_sms_count = 0
      @user.save
      render json: @user, serializer: UserAuthSerializer, root: "user"
    else
      render json: {auth_token: ""}, status: Code[:status_error]
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
  end

  # DELETE /users/1.json
  def destroy
    current_user.destroy
    render json: { head: :no_content }
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
  end

  # GET /users/services/chats
  def user_services_chat_list
    @chats = current_user.chats.includes(:service).group_by{|c| c.service_id.to_s }
    render :text => @chats.each_pair{|k, v| k}
    # pending
  end

  # GET /users/services/:service_id/chats
  def user_service_chats
    @chats = current_user.chats.where(service_id: params[:service_id])
    render :text => @chats.each_pair{|k| k}
    # pending
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

