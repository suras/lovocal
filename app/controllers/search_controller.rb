class SearchController < ApplicationController
  
  # GET /search 
  def search
  	params[:search][:distance] = 50 if params[:search][:distance].blank?
    distance = params[:search][:distance].to_i
  	latitude = params[:search][:latitude].to_f 
  	longitude = params[:search][:longitude].to_f
  	if(params[:search][:listing_category].present?)
  	  list_cat_ids = ListingCategory.where(name: /#{params[:search][:listing_category]}/)
      @category = list_cat_ids[0] 
      list_cat_ids = list_cat_ids.map{|l| l.id.to_s}
      if(latitude != 0.0 && longitude != 0.0)
        @services = Service.where(:list_cat_ids.in => list_cat_ids).page(params[:page]).per(params[:per]).geo_near([latitude, longitude]).max_distance(distance).to_a
      else
        @services = Service.where(:list_cat_ids.in => list_cat_ids).page(params[:page]).per(params[:per])
      end
  	elsif(params[:search][:service_name].present?)
      if(latitude != 0.0 && longitude != 0.0)
        @services = Service.where(:business_name => /#{params[:search][:service_name]}/).page(params[:page]).per(params[:per]).geo_near([latitude, longitude]).max_distance(distance).to_a
      else
        @services = Service.where(:business_name => /#{params[:search][:service_name]}/).page(params[:page]).per(params[:per])
      end
  	else
      @services = Service.all.page(params[:page]).per(params[:per])
  	end
  	respond_to do |format|
      format.html { render "search"}
    end 
  end

end
