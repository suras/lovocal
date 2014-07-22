class Api::V1::ServiceRatingsController < Api::V1::BaseController
  before_action :authenticate_user!, except: [:index]
  before_action :set_service, only: [:create, :index]

  # GET /services/service_rating
  def index
    @service_ratings = @service.service_ratings
    render json: @service_ratings
  rescue => e
     render json: {error_code: Code[:error_rescue], error_message: e.message}, status: Code[:status_error]
  end

  # POST /services/service_rating
  def create 
    @service_rating = @service.service_ratings.new(service_rating_params)
    @service_rating.user = current_user
    if(@service_rating.save)
      render json: @service_rating
    else
      render json: {error_code: Code[:error_rescue], error_message: @service_rating.errors.full_messages}, status: Code[:status_error]
    end
  rescue => e
     render json: {error_code: Code[:error_rescue], error_message: e.message}, status: Code[:status_error]
  end

  # PATCH/PUT /services/:service_id/service_rating
  def update
  	@service_rating = current_user.service_ratings.find(params[:id])
    if(@service_rating.update_attributes(service_rating_params))
      render json: @service_rating
    else
      render json: {error_code: Code[:error_rescue], error_message: @service_rating.errors.full_messages}, status: Code[:status_error]
    end
  rescue => e
     render json: {error_code: Code[:error_rescue], error_message: e.message}, status: Code[:status_error]
  end

  # DELETE /services/:service_id/service_rating
  def destroy
    @service_rating = current_user.service_ratings.find(params[:id])
    @service_rating.destroy
    render json: { head: :no_content}
  rescue => e
    render json: {error_code: Code[:error_rescue], error_message: e.message}, status: Code[:status_error]
  end

  private
  
  def set_service
  	return nil if params[:service_id].blank?
    @service = Service.find(params[:service_id])
  end

  def service_rating_params
    params.require(:service_rating).permit(:comment, :rating)
  end

end
