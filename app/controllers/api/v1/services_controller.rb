class Api::V1::ServicesController < Api::V1::BaseController
  before_action :authenticate_user!
  
  # POST /listing_category
  def create 
    list_cat_ids = get_list_cat_ids_by_name
    @service = current_user.services.new(service_params.merge(list_cat_ids: list_cat_ids ))
    @service.listing = Listing.where(name: "services").first
    if(@service.save)
      render json: @service
    else
      render json: @service.errors.full_messages
    end
  rescue => e
     render json: {error_code: Code[:error_rescue], error_message: e.message}, status: Code[:status_error]
  end

  # PATCH/PUT /services
  def update
  	@service = currrent_user.services.find(params[:id])
    if(@service.update_attributes(service_params))
      render json: @service
    else
      render json: @service.errors.full_messages
    end
  rescue => e
     render json: {error_code: Code[:error_rescue], error_message: e.message}, status: Code[:status_error]
  end

  # DELETE /services
  def destroy
    @service = current_user.services.find(params[:id])
    @service.destrtoy
    render json: { head: :no_content}
  rescue => e
    render json: {error_code: Code[:error_rescue], error_message: e.message}, status: Code[:status_error]
  end

  # DELETE /services/:service_id/service_images
  def destroy_images
    @service = current_user.services.find(params[:service_id])
    @service.service_images.where(id: params[:ids]).destroy
  end

  # POST /services/:service_id/service_images
  def create_images
    @service = current_user.services.find(params[:service_id])
    params[:service_images].each do |image|
      @service.service_images.create!(image: image)
    end
    render json: {service_images: @service.service_images}
  rescue => e
    render json: {error_code: Code[:error_rescue], error_message: e.message}, status: Code[:status_error]
  end

  private
    # Never trust parameters from the scary internet, only allow the white list through.
    def service_params
      params.require(:service).permit(:business_name, :mobile_number, :landline_number, 
      	:email, :description, :customer_care_no, :latitude, 
      	:longitude, :country, :state, :city, :zip_code, :website, :facebook_link,
        :twitter_link, :linkedin_link, :listing_categories, service_images_attributes: [:image]
      	 )
    end

    def get_list_cat_ids_by_name
	  ids = Array.new
	  params[:service][:listing_categories].each do |cat|
        list_cat = ListingCategory.where(name: cat).first
        ids << list_cat.id.to_s if list_cat.present?
	  end
	  return ids
    end

end


