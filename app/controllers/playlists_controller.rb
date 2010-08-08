class PlaylistsController < ApplicationController

  respond_to :html, :json, :js

  before_filter :find_playlist, :only => [:show, :load, :edit, :update, :destroy]

  # GET /playlists
  def index
    @playlists = Playlist.all
    respond_with @playlists
  end

  # GET /playlists/1
  def show
    respond_with @playlist
  end

  # GET /playlists/1/load
  def load
    current_playlist = @playlist
    respond_with @playlist
  end

  # GET /playlists/new
  def new
    @playlist = Playlist.new
    respond_with @playlist
  end

  # GET /playlists/1/edit
  def edit
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
    @playlist.update_attributes(params[:playlist])
    respond_with @playlist
  end

  # DELETE /playlists/1
  def destroy
    flash[:notice] = 'Playlist was successfully destroyed.' if @playlist.destroy
    respond_with @playlist
  end

  private

  def find_playlist
    @playlist = params[:id] == Playlist::CURRENT ? current_playlist : Playlist.find(params[:id])
  end

end
