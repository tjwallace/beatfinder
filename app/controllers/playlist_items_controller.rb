class PlaylistItemsController < ApplicationController
  before_filter :find_playlist
  
  def index
    render :text => "#{params[:playlist_id]}"    
  end
  
  def show
    
  end
  
  def new
    
  end
  
  def create
    
  end
  
  private
  
  def find_playlist
    @playlist = params[:id] == 'current' ? current_playlist : Playlist.find(params[:id])
  end
end
