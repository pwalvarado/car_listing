class ListingsController < ApplicationController
  before_filter :require_user_logged_in, only: [:new, :create, :edit, :update, :destroy]
  before_filter :require_owner, only: [:edit, :update, :destroy]

  def index
    params[:search] ||= {}
    params[:page] ||= 1
    @makes_array = Subdivision.where(level: 0).order(:name).
                               all.map { |make| [make.name, make.id] }
    @models_array = Subdivision.where(level: 1).order(:name).
                                all.map { |model| [model.name, model.id] }

    @listings = Listing.search(params[:search], params[:page])

    @sort_options = [["oldest first", "post_date_asc"],
                     ["newest first", "post_date_desc"],
                     ["lowest price", "price_asc"],
                     ["highest price", "price_desc"],
                     ["distance", "distance"]]

    zip = params[:search][:zip]
    if zip && zip.length > 1 && !Zip.find_by_code(zip)
      flash[:alert] = "Invalid zipcode. Please check your input."
    end

    if request.xhr?
      #sleep 1 if Rails.env.development?
      render @listings
    end
  end

  def show
    @listing = Listing.includes(:make, :model, :pics, :main_pic).find(params[:id])
  end

  def new
    @listing = current_user.listings.new
  end


  def create
    @listing = current_user.listings.new(params[:listing])
    @listing.pics.new(params[:pics])

    if @listing.save
      flash[:success] = "Successfully listed your #{@listing.name}"
      redirect_to @listing
    else
      flash.now[:alert] = "Couldn't save your listing. Check below."
      render :new
    end
  end


  def edit
    @listing = Listing.find(params[:id])
  end


  def update
    @listing = Listing.find(params[:id])

    if @listing.update_attributes(params[:listing])
      flash[:success] = "Successfully saved changes to your #{@listing.name}"
      redirect_to @listing
    else
      flash.now[:alert] = "Couldn't save changes to your #{@liasting.name || 'listing'}. Check below."
      render :edit
    end
  end

  def destroy
    @listing = Listing.find(params[:id])

    @listing.destroy

    flash[:succes] = "Successfully removed your #{@listing.name} from our listings."
    redirect_to current_user
  end
end
