class SongsController < ApplicationController
  # GET /songs
  def index
    if params[:site_id]
      @songs = Site.find(params[:site_id]).songs.active
    else
      @songs = Song.order("created_at DESC").all
    end
  end
  
  # GET /songs/recent
  def recent
    @songs = Song.active.recent
    render :index
  end

  # GET /songs/1
  def show
    @song = Song.find(params[:id])
    respond_to do |wants|
      wants.html
      wants.mp3 { send_file @song.filename, :filename => @song.download_filename }
    end
  end

  # GET /songs/new
  def new
    @song = Song.new
  end

  # GET /songs/1/edit
  def edit
    @song = Song.find(params[:id])
  end

  # POST /songs
  def create
    @song = Song.new(params[:song])
    
    if @song.save
      redirect_to(@song, :notice => 'Song was successfully created.')
    else
      render :action => "new"
    end
  end

  # PUT /songs/1
  def update
    @song = Song.find(params[:id])

    if @song.update_attributes(params[:song])
      redirect_to(@song, :notice => 'Song was successfully updated.')
    else
      render :action => "edit"
    end
  end

  # DELETE /songs/1
  def destroy
    @song = Song.find(params[:id]).destroy
    redirect_to(songs_url)
  end
end
