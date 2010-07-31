class ApplicationController < ActionController::Base
  protect_from_forgery
  layout 'application'
  helper :layout

  before_filter :find_current_playlist

  def find_current_playlist
    if session[:playlist_id].nil?
      @current_playlist = Playlist.create(:name => 'New playlist')
      session[:playlist_id] = @current_playlist.id
    else
      @current_playlist = Playlist.find(session[:playlist_id])
    end
  end

end
