class PublicController < ApplicationController
  
  def index
  
  end

  # GET /banners
  def banners
    @banners = Banner.all.desc(:priority)
    render json: @banners
  end

end
