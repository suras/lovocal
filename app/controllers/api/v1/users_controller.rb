class Api::V1::UsersController < Api::V1::BaseController
  
  # GET /user_profile
  def user_profile
    user  = User.find( params[:id])
    render json: user, serializer: UserProfileSerializer
  rescue => e
    render json: {error_code: Code[:error_rescue], error_message: e.message}, status: Code[:status_error]
  end

  # GET '/users/id'
  def show
    user  = current_user
    render :json => user
  rescue => e
     render json: {error_code: Code[:error_rescue], error_message: e.message}, status: Code[:status_error]
  end

  # POST '/users'
  def create
    @user = User.new(user_params)
    if(@user.save)
      render json: @user
    else
      render json: {error_code: Code[:error_rescue], error_message: @user.errors.full_messages}, status: Code[:status_error]
    end
  rescue => e
     render json: {error_code: Code[:error_rescue], error_message: e.message}, status: Code[:status_error]
  end

  # POST '/login'
  def login
    if(params[:user][:phone_id].present? && params[:user][:serial_key].present?)
      @user = User.where(encrypted_phone_id: params[:user][:phone_id], sms_serial_key: params[:user][:sms_serial_key])
      render json: @user
    else
      render json: {error_code: Code[:error_rescue], error_message: "User Not Present"}, status: Code[:status_error]
    end
  end

  # PUT/PATCH '/users/id'
  def update
    user  = current_user
    if(user.update_attributes(user_params))
      render json: user
    else
      render json: {error_code: Code[:error_resource], error_message: user.errors.full_messages},  status: Code[:status_error]
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

  private
    # Never trust parameters from the scary internet, only allow the white list through.
    def user_params
      params.require(:user).permit(:first_name, :last_name, :mobile_number, :email, 
        :image, :description)
    end

end
