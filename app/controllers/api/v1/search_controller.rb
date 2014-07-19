class Api::V1::SearchController < Api::V1::BaseController
  
  # GET /search 
  def search
  	params[:search][:distance] = 50 if params[:search][:distance].blank?
  	latitude = params[:search][:latitude].to_f
  	longitude = params[:search][:longitude].to_f
  	if(params[:search][:listing_category].present?)
  	  list_cat_ids = ListingCategory.where(name: /#{params[:search][:listing_category]}/)
      @services = Service.where(:list_cat_id.in => list_cat_ids).geo_near([latitude, longitude]).max_distance(params[:search][:distance]).page(params[:page]).per(params[:per])
  	elsif(params[:search][:service_name].present?)
      @services = Service.where(:business_name => /#{params[:search][:service_name]}/).geo_near([latitude, longitude]).max_distance(params[:search][:distance])
  	else
      @services = Service.all.page(params[:page]).per(params[:per])
  	end
  	render json: @services
  rescue => e
     render json: {error_code: Code[:error_rescue], error_message: e.message}, status: Code[:status_error]
  end

end
