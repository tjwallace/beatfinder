class ApplicationController < ActionController::Base
  protect_from_forgery
  layout 'application'
  helper :layout

  before_filter :find_current_playlist

  def find_current_playlist
    current_playlist
  end

  def current_playlist
    @current_playlist ||= Playlist.find(current_playlist_id)
  end

  def current_playlist=(playlist)
    @current_playlist = playlist
    session[:playlist_id] = playlist.id
  end

  def current_playlist_id
    session[:playlist_id] ||= Playlist.create(:name => "New playlist").id
  end

end
