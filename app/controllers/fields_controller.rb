class FieldsController < ApplicationController
  before_filter :admin_player  

  def new
    @field = Field.new
  end

  def create
    @field = Field.new(params[:field])
    if @field.save
      flash[:success] = 'Field created!'
      redirect_to root_url
    else
      render 'new'
    end
  end

  private

    def admin_player
      redirect_to(root_path) unless current_player.admin? 
    end
end
