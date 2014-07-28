class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  
  before_filter :set_trending
  def set_trending
    @trending1 = "blackkeys"
     @trending2 = "vice"
      @trending3 = "latenight"
  end
  
  
end
