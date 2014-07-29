class SearchController < ApplicationController
  
  # GET /search 
  def search
  	params[:search][:distance] = 50 if params[:search][:distance].blank?
    distance = params[:search][:distance].to_i
  	latitude = params[:search][:latitude].to_f
  	longitude = params[:search][:longitude].to_f
  	if(params[:search][:listing_category].present?)
  	  list_cat_ids = ListingCategory.where(name: /#{params[:search][:listing_category]}/)
      list_cat_ids = list_cat_ids.map{|l| l.id.to_s}
      @services = Service.where(:list_cat_ids.in => list_cat_ids).page(params[:page]).per(params[:per]).geo_near([latitude, longitude]).max_distance(distance)
  	  @services = @services.to_a
  	elsif(params[:search][:service_name].present?)
      @services = Service.where(:business_name => /#{params[:search][:service_name]}/).page(params[:page]).per(params[:per]).geo_near([latitude, longitude]).max_distance(distance)
  	  @services = @services.to_a
  	else
      @services = Service.all.page(params[:page]).per(params[:per])
  	end
  	respond_to do |format|
      format.html { redirect_to search_url}
      format.json { render @services, status: :ok}
    end 
  end

end
