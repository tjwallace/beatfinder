class PlaylistsController < ApplicationController

  respond_to :html, :json

  # GET /playlists
  def index
    @playlists = Playlist.all
    respond_with @playlists
  end

  # GET /playlists/1
  def show
    @playlist = params[:id] == 'current' ? current_playlist : Playlist.find(params[:id])

    respond_with @playlist
  end

  # GET /playlists/new
  def new
    @playlist = Playlist.new
    respond_with @playlist
  end

  # GET /playlists/1/edit
  def edit
    @playlist = Playlist.find(params[:id])
    respond_wtih @playlist
  end

  # POST /playlists
  def create
    @playlist = Playlist.new(params[:playlist])
    flash[:notice] = 'Playlist was successfully created.' if @playlist.save
    respond_with @playlist
  end

  # PUT /playlists/1
  def update
    @playlist = Playlist.find(params[:id])
    flash[:notice] = 'Playlist was successfully updated.' if @playlist.update_attributes(params[:playlist])
    respond_with @playlist
  end

  # DELETE /playlists/1
  def destroy
    @playlist = Playlist.find(params[:id])
    flash[:notice] = 'Playlist was successfully destroyed.' if @playlist.destroy
    respond_with @playlist
  end

end
