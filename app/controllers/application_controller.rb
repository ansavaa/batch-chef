class ApplicationController < ActionController::Base
  allow_browser versions: :modern

  stale_when_importmap_changes

  helper_method :current_user, :logged_in?

  before_action :set_current_user

  private

  def current_user
    @current_user
  end

  def logged_in?
    current_user.present?
  end

  def set_current_user
    @current_user = User.find_by(id: session[:user_id])
  end
end
