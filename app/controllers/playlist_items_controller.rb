class PlaylistItemsController < ApplicationController
  respond_to :html, :js

  before_filter :find_playlist
  
  def index
    render :text => "#{params[:playlist_id]}"    
  end
  
  def show
    
  end
  
  def new
    
  end
  
  def create
   @playlist_item = @playlist.items.build(:song_id => params[:song_id])
   flash[:notice] = "Song added to playlist" if @playlist_item.save
   respond_with @playlist_item
  end

  def destroy
    @playlist_item = PlaylistItem.find(params[:id])
    flash[:notice] = "Song removed from playlist" if @playlist_item.destroy
    respond_with @playlist_item
  end
  
  private
  
  def find_playlist
    @playlist = params[:playlist_id] == Playlist::CURRENT ? @current_playlist : Playlist.find(params[:playlist_id])
  end
end
