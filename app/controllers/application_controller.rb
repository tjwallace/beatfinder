class ApplicationController < ActionController::Base
  protect_from_forgery
  layout 'application'
  helper :layout

  def current_playlist
    session[:playlist] ||= Playlist.new :name => 'New playlist'
  end

end
