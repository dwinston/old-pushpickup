class FieldsController < ApplicationController
  before_filter :signed_in_player, except: [:index, :show]
  before_filter :admin_player, except: [:index, :show]  

  def show
    @field = Field.find_by_id(params[:id])
    @availability = (signed_in? && current_player.availabilities.build(session[:availability_params])) || Availability.new
    @game_feed_items = @field.games.future
    redirect_to fields_path, alert: "Field not found." unless @field
  end

  def index
    params[:city_ids] ||= City.pluck(:id)
    @fields = params[:city_ids].flat_map { |id| City.find_by_id(id).fields }
    @cities = params[:city_ids]
    @field_markers = @fields.to_gmaps4rails do |field, marker|
      marker.infowindow render_to_string(partial: '/shared/field_info', locals: {field: field}) 
    end if !Rails.env.test?
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
      redirect_to @field
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
      redirect_to @field
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
