class Api::V1::PublicController < Api::V1::BaseController
  
  def index
  
  end

  # GET /banners
  def banners
    @banners = Banner.all.desc(:priority)
    render json: @banners, root: :banners
  end

end
