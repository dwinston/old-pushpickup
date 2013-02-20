module SessionsHelper

  def sign_in(player)
    cookies.permanent[:remember_token] = player.remember_token # 20.years.from_now
    self.current_player = player
  end

  def signed_in?
    !current_player.nil?
  end

  def sign_out
    self.current_player = nil
    cookies.delete(:remember_token)
  end

  def current_player=(player)
    @current_player = player
  end

  def current_player
    @current_player ||= Player.find_by_remember_token(cookies[:remember_token])
  end

  def current_player?(player)
    player == current_player
  end

  def redirect_back_or(default)
    redirect_to(session[:return_to] || default)
    session.delete :return_to
  end

  def store_location
    session[:return_to] = request.url
  end
end
