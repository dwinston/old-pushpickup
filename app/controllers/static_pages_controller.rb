class StaticPagesController < ApplicationController
  def home
    if signed_in?
      @availability = current_player.availabilities.build 
      @feed_items = current_player.feed.paginate(page: params[:page])
    end
  end

  def help
  end
  
  def about
  end
end
