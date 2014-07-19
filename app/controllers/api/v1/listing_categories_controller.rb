class Api::V1::ListingCategoriesController < Api::V1::BaseController
 
  # GET /listing_category  
  def index
    @listing_categories = ListingCategory.roots
    render json: @listing_categories
  rescue => e
     render json: {error_code: Code[:error_rescue], error_message: e.message}, status: Code[:status_error]
  end

  # POST /listing_category
  def create 
    @listing_category = ListingCategory.new(listing_category_params)
    if(@listing_category.save)
      render json: @listing_category
    else
      render json: @listing_category.errors.full_messages
    end
  rescue => e
     render json: {error_code: Code[:error_rescue], error_message: e.message}, status: Code[:status_error]
  end

  #POST /listing_category_children/:id
  def create_children
  	@listing_parent_category = ListingCategory.find(params[:category_id])
    @listing_children_category = ListingCategory.new(listing_category_params)
    if(@listing_children_category.save)
      @listing_parent_category.children << @listing_children_category
      render json: @listing_children_category
    else
      render json: @listing_children_category.errors.full_messages
    end
  rescue => e
     render json: {error_code: Code[:error_rescue], error_message: e.message}, status: Code[:status_error]
  end

  # GET /listing_category_children
  def show_listing_category_children
    @listing_category = ListingCategory.find(params[:category_id])
    @children = @listing_category.children
    render json: @children
  rescue => e
     render json: {error_code: Code[:error_rescue], error_message: e.message}, status: Code[:status_error]
  end

  #  PATCH /listing_category
  def update
    @listing_category = ListingCategory.find(params[:id])
    if(@listing_category.update_attributes(listing_category_params))
      render json: @listing_category
    else
      render json: @listing_category.errors.full_messages
    end
  rescue => e
     render json: {error_code: Code[:error_rescue], error_message: e.message}, status: Code[:status_error]    
  end

  # DELETE /listing_category/1.json
  def destroy
    @listing_category = ListingCategory.find(params[:id])
    @listing_category.destroy
    render json: { head: :no_content }
  rescue => e
    render json: {error_code: Code[:error_rescue], error_message: e.message}, status: Code[:status_error]
  end

  private
    # Never trust parameters from the scary internet, only allow the white list through.
    def listing_category_params
      params.require(:listing_category).permit(:name)
    end

end
