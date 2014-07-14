class PlaylistsController < ApplicationController
  before_action :set_playlist, only: [:show, :edit, :update, :destroy]
  require 'open-uri'

  # GET /playlists
  # GET /playlists.json
  def index
    @stream = Stream.friendly.find(params[:stream_id]) 
    
    if user_signed_in?
    @addkey = @stream.admins.find_by admin_key: current_user.id    
    end
    
    @playlists = Playlist.all
    
  end
  
  
  def filter
    @stream = Stream.friendly.find(params[:stream_id]) 
    @playlist = @stream.playlists.where(stream_id: @stream.id)
    
  end

  # GET /playlists/1
  # GET /playlists/1.json
  def show
    
  end

  # GET /playlists/new
  def new
    @playlist = Playlist.new
  end

  # GET /playlists/1/edit
  def edit
  end

  # POST /playlists
  # POST /playlists.json
  def create    
    @stream = Stream.friendly.find(params[:stream_id]) 
    @playlist = @stream.playlists.find_or_initialize_by(playlist_params)
    
    if @playlist.valid?
      
    @playlist.playlist_id = @playlist.playlistconverturl(@playlist.url)
    
    @playlist.title = @playlist.get_youtube_playlist_title(@playlist.playlist_id)
        
    @stream.delay.download_playlist_videos(@playlist.playlist_id)

    end
    
    respond_to do |format|
      if @playlist.save
        @stream.save
        format.html { redirect_to edit_stream_path(@stream), notice: 'Playlist was successfully created.' }
        format.json { render :show, status: :created, location: @playlist }
      else
        format.html { render :new }
        format.json { render json: @playlist.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /playlists/1
  # PATCH/PUT /playlists/1.json
  def update
    respond_to do |format|
      if @playlist.update(playlist_params)
        format.html { redirect_to @playlist, notice: 'Playlist was successfully updated.' }
        format.json { render :show, status: :ok, location: @playlist }
      else
        format.html { render :edit }
        format.json { render json: @playlist.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /playlists/1
  # DELETE /playlists/1.json
  def destroy
    @stream = Stream.friendly.find(params[:stream_id]) 
    
    videos_from_playlist = @stream.videos.where(:pid => @playlist.playlist_id )
    videos_from_playlist.destroy_all
    @playlist.destroy

    respond_to do |format|
      format.html { redirect_to edit_stream_path(@stream), notice: 'Playlist was successfully removed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_playlist
      @playlist = Playlist.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def playlist_params
      params.require(:playlist).permit(:url, :title)
    end
end
