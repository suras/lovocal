class ServiceRatingsController < ApplicationController
  before_action :authenticate_user!, except: [:index, :show]
  before_action :set_service, only: [:create, :index]

  # GET /services/service_rating
  def index
    @service_ratings = @service.service_ratings
  end

  # POST /services/service_rating
  def create 
    @service_rating = @service.service_ratings.new(service_rating_params)
    @service_rating.user = current_user
    respond_to do |format|
      if(@service_rating.save)
        format.html { redirect_to @service_rating, notice: 'Service Rating was successfully created.' }
        format.json { render :show, status: :created, location: @service_rating }
      else
        format.html { render :new }
        format.json { render json: @service_rating.errors, status: :unprocessable_entity }
      end
    end
  end

  # GET  /services/:service_id/service_rating/
  def show
    @service_rating = @service.service_ratings.find(params[:id])
  end

  # GET  /services/:service_id/service_rating/new
  def new
    @service_rating = @service.service_ratings.new
  end
  
  # GET /services/:service_id/service_rating/edit
  def edit
    @service_rating = current_user.service_ratings.find(params[:id])
  end

  # PATCH/PUT /services/:service_id/service_rating
  def update
  	@service_rating = current_user.service_ratings.find(params[:id])
    respond_to do |format|
      if(@service_rating.update_attributes(service_rating_params))
        format.html { redirect_to @service_rating, notice: 'Service rating was successfully updated.' }
        format.json { render :show, status: :ok, location: @service_rating }
      else
        format.html { render :edit }
        format.json { render json: @service_rating.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /services/:service_id/service_rating
  def destroy
    @service_rating = current_user.service_ratings.find(params[:id])
    @service_rating.destroy
    render json: { head: :no_content}
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
