class FieldsController < ApplicationController
  before_filter :signed_in_player
  before_filter :admin_player, except: :index  

  def index
    if params[:city_id].present?
      @fields = params[:city_id].flat_map { |id| City.find_by_id(id).fields }
      @cities = params[:city_id]
      store_location
    else
      @fields = []
      @cities = []
    end
  end

  def new
    @field = Field.new
  end

  def create
    # the following is a hack that should be refactored by using
    # accepts_nested_attributes_for in creating a field through the city association
    city = City.find_by_id(params[:field][:city_id])
    params[:field].delete :city_id
    @field = city.fields.build(params[:field])

    if @field.save
      flash[:success] = 'Field created!'
      redirect_back_or root_url
    else
      render 'new'
    end
  end

  def edit
    @field = Field.find_by_id(params[:id])
  end

  def update
    @field = Field.find_by_id(params[:id])
    if @field.update_attributes(params[:field])
      flash[:success] = 'Field updated'
      redirect_back_or root_url
    else
      render 'edit'
    end
  end

  def destroy
    @field = Field.find(params[:id])
    @field.destroy
    flash[:success] = 'Field destroyed'
    redirect_back_or root_url
  end

  private

    def admin_player
      redirect_to(root_path) unless current_player.admin?
    end
end
