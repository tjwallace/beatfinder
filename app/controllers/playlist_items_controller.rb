class PlaylistItemsController < ApplicationController
  respond_to :js
  layout nil

  before_filter :find_playlist
  before_filter :find_playlist_item, :only => [:update, :destroy]
  
  def create
   @playlist_item = @playlist.items.build(:song_id => params[:song_id])
   @playlist_item.save
   respond_with @playlist_item
  end

  def update
    @playlist_item.insert_at(params[:position])
    respond_with @playlist_item
  end

  def destroy
    @playlist_item.destroy
    respond_with @playlist_item
  end
  
  private
  
  def find_playlist
    if !user_signed_in? || params[:playlist_id] == Playlist::CURRENT
      @playlist = current_playlist
    else
      @playlist = current_user.playlists.find(params[:playlist_id])
    end
  end

  def find_playlist_item
    @playlist_item = @playlist.items.find(params[:id])
  end
end
