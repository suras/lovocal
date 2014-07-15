class Api::V1::UsersController < Api::V1::BaseController
  
  # GET /user_profile
  def user_profile
    user  = User.find( params[:id])
    if stale?(:etag => "user_profile_"+user.id, :last_modified => user.updated_at, :public => true)
      render json: user, serializer: UserProfileSerializer
    end
  rescue => e
    render json: {error_code: Code[:error_rescue], error_message: e.message}, status: Code[:status_error]
  end

  # GET '/users/id'
  def show
    user  = current_user
    if stale?(:etag => "current_user_profile_"+user.id, :last_modified => user.updated_at, :public => true)
      render :json => user
    end
  rescue => e
     render json: {error_code: Code[:error_rescue], error_message: e.message}, status: Code[:status_error]
  end

  # POST '/users'
  def create
    @user = User.new(user_params)
    if(@user.save)
      render json: @user
    else
      render json: error_message: @user.errors
    end
  rescue => e
     render json: {error_code: Code[:error_rescue], error_message: e.message}, status: Code[:status_error]
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
