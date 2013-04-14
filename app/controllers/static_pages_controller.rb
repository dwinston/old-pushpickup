class StaticPagesController < ApplicationController
  def home
    if signed_in?
      @availability = current_player.availabilities.build 
      @availability_feed_items = current_player.availability_feed
      @game_feed_items = current_player.game_feed
    else
      @field_markers = Field.all.to_gmaps4rails do |field, marker|
        marker.infowindow render_to_string(partial: '/shared/field_info', locals: {field: field}) 
      end if !Rails.env.test?
    end
  end

  def help
  end
  
  def about
  end
end
