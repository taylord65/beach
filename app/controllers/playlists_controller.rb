class PlaylistsController < ApplicationController
  before_action :set_playlist, only: [:show, :edit, :update, :destroy]

  # GET /playlists
  # GET /playlists.json
  def index
    @stream = Stream.friendly.find(params[:stream_id]) 
    
    @playlists = Playlist.all
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
    @playlist = @stream.playlists.find_or_create_by(playlist_params)
    
    @playlist.playlist_id = @playlist.playlistconverturl(@playlist.url)
    @playlist.title = @playlist.get_youtube_playlist_title(@playlist.playlist_id)
    doc = Nokogiri::XML(open("http://gdata.youtube.com/feeds/api/playlists/#{@playlist.playlist_id}?v=2"))   
    @scrapeurl = doc.xpath('//media:content')[1]['url']
    
    respond_to do |format|
      if @playlist.save
        @video = @stream.videos.find_or_create_by(:url => @scrapeurl)
        @video.video_id = @video.converturl(@video.url)
        @video.length = @video.get_youtube_video_duration(@video.video_id)
        @video.name = @video.get_youtube_video_name(@video.video_id)
        @video.save
        
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
    
    @playlist.destroy
    respond_to do |format|
      format.html { redirect_to edit_stream_path(@stream), notice: 'Playlist was successfully destroyed.' }
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
