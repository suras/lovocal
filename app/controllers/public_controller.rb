class PublicController < ApplicationController
  
  def index
  
  end

  # GET /banners
  def banners
    @banners = Banner.all.desc(:priority)
    render json: @banners, root: :banners
  end

end
