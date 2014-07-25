class ServicesController < ApplicationController
before_action :authenticate_user!
  
  # POST /listing_category
  def create 
    @service = current_user.services.new(service_params)
    @service.listing = Listing.where(listing_type: "services").first
    respond_to do |format|
      if @service.save
        format.html { redirect_to @service, notice: 'service was successfully created.' }
        format.json { render :show, status: :created, location: @service }
      else
        format.html { render :new }
        format.json { render json: @service.errors, status: :unprocessable_entity }
      end
    end
  end

  def edit
    @service = current_user.services.find(params[:id])
  end

  def show
    @service = current_user.services.find(params[:id])
  end

  def new
    @service = current_user.services.new
  end

  # PATCH/PUT /services
  def update
  	@service = currrent_user.services.find(params[:id])
    respond_to do |format|
      if @service.update(service_params)
        format.html { redirect_to @service, notice: 'service was successfully updated.' }
        format.json { render :show, status: :ok, location: @service }
      else
        format.html { render :edit }
        format.json { render json: @service.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /services
  def destroy
    @service = current_user.services.find(params[:id])
    respond_to do |format|
      format.html { redirect_to services_url, notice: 'Service was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  # DELETE /services/:service_id/service_images
  def destroy_images
    @service = current_user.services.find(params[:service_id])
    @service.service_images.where(:_id.in => params[:service_image][:ids]).destroy   
    respond_to do |format|
      format.html { redirect_to @service, notice: 'Images was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def new_images
    @service = current_user.services.find(params[:id])
  end
  # POST /services/:service_id/service_images
  def create_images
    @service = current_user.services.find(params[:service_id])
    params[:service_image][:image].each do |image|
      @service.service_images.create!(image: image)
    end
    respond_to do |format|
      format.html { redirect_to @service, notice: 'Images was successfully created.' }
      format.json { json: @service, status: :ok, location: @service  }
    end
  rescue => e
  	respond_to do |format|
      format.html { render :create_new_images}
      format.json { json: @service.errors, status: :unprocessable_entity}
    end
  end

  def timing
    @service = current_user.services.find(params[:service_id])
    @service_timing = @service.service_timing
    unless(@service.service_timing.present?)
      @service_timing = @service.build_service_timing
    end
  end

  # POST services/service_id/service_timings
  def create_timings
    @service = current_user.services.find(params[:service_id])
    @service_timing = @service.build_service_timing
    @service_timing.timings = {}
    timing_pair = JSON.parse(params[:service_timing][:timings])
    timing_pair.each_pair do |day, time|
      @service_timing.timings[day] = time
    end
    @service_timing.holidays = params[:service_timing][:holidays]
    respond_to do |format|
      if(@service_timing.save)
        format.html { redirect_to @service_timing, notice: 'service was successfully updated.' }
        format.json { render :show, status: :ok, location: @service }
      else
        format.html { render :timing }
        format.json { render json: @service_timing.errors, status: :unprocessable_entity }
      end
    end
  end

  # GET /services/:id/rating
  def rating
    @service  =  Service.find(params[:id])
    avg = @service.avg_rating
  	respond_to do |format|
      format.html { redirect_to @service}
      format.json { json: avg, status: :ok}
    end 
  end

  private
    # Never trust parameters from the scary internet, only allow the white list through.
    def service_params
      params.require(:service).permit(:business_name, :mobile_number, :landline_number, 
      	:email, :description, :customer_care_no, :latitude, :address, {list_cat_ids: []},
      	:longitude, :country, :state, :city, :zip_code, :website, :facebook_link,
        :twitter_link, :linkedin_link, {service_images_attributes: [:image, :is_main]}
      	 )
    end

    def get_list_cat_ids_by_name
	  ids = Array.new
	  params[:service][:listing_categories].try(:each) do |cat|
        list_cat = ListingCategory.where(name: cat).first
        ids << list_cat.id.to_s if list_cat.present?
	  end
	  return ids
    end
end
