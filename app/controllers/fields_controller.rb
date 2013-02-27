class FieldsController < ApplicationController
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
end
