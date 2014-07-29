class ListingCategoriesController < ApplicationController
 
  # GET /listing_category  
  def index
    @listing_categories = ListingCategory.roots
  end

  # POST /listing_category
  def create 
    @listing_category = ListingCategory.new(listing_category_params)
    respond_to do |format|
      if(@listing_category.save)
        format.html { redirect_to @service_rating, notice: 'Listing Category was successfully created.' }
        format.json { render :show, status: :created, location: @listing_category }
      else
        format.html { render :new }
        format.json { render json: @listing_category.errors, status: :unprocessable_entity }
      end
    end
  end

  #POST /listing_category_children/:id
  def create_children
  	@listing_parent_category = ListingCategory.find(params[:category_id])
    @listing_children_category = ListingCategory.new(listing_category_params)
  	respond_to do |format|
    	if(@listing_children_category.save)
    	  @listing_parent_category.children << @listing_children_category
    	  format.html { redirect_to @listing_children_category, notice: 'subcategory was successfully created.' }
    	  format.json { render :show, status: :created, location: @listing_children_category }
    	else
    	  format.html { render :new }
    	  format.json { render json: @listing_children_category.errors, status: :unprocessable_entity }
    	end
   end
 end

  # GET /listing_category_children
  def show_listing_category_children
    @listing_category = ListingCategory.find(params[:category_id])
    @children = @listing_category.children
  end

  #  PATCH /listing_category
  def update
    @listing_category = ListingCategory.find(params[:id])
    respond_to do |format|
      if(@listing_category.update_attributes(listing_category_params))
        format.html { redirect_to @listing_category, notice: 'Listing category was successfully updated.' }
        format.json { render :show, status: :ok, location: @listing_category }
      else
        format.html { render :edit }
        format.json { render json: @listing_category.errors.full_messages, status: :unprocessable_entity }
      end
    end
  end


  # DELETE /listing_category/1.json
  def destroy
    @listing_category = ListingCategory.find(params[:id])
    @listing_category.destroy
    respond_to do |format|
      format.html { redirect_to listing_categories__url, notice: 'Listing category was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Never trust parameters from the scary internet, only allow the white list through.
    def listing_category_params
      params.require(:listing_category).permit(:name)
    end
end
