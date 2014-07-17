class VideosController < ApplicationController
  before_action :set_video, only: [:show, :edit, :update, :destroy]  

  # GET /videos
  # GET /videos.json
  def index
    @videos = Video.all
  end

  # GET /videos/1
  # GET /videos/1.json
  def show
  end

  # GET /videos/new
  def new
    @video = Video.new
  end

  # GET /videos/1/edit
  def edit
  end
  
  
  # POST /videos
  # POST /videos.json
  def create
    @stream = Stream.friendly.find(params[:stream_id]) 
    @video = @stream.videos.find_or_create_by(video_params)
    
    @video.video_id = @video.converturl(@video.url)
    
    if @stream.videos.where(video_id: @video.video_id).blank?
    
    @video.length = @video.get_youtube_video_duration(@video.video_id)
    @video.name = @video.get_youtube_video_name(@video.video_id)
    @video.y_date_added = @video.get_youtube_video_date(@video.video_id)
    
    end
 
    respond_to do |format|
      if @video.save
        format.html { redirect_to edit_stream_path(@stream), notice: '✓ Video was successfully created' }
        format.json { render :show, status: :created, location: @video }
      else
        format.html { render :new }
        format.json { render json: @video.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /videos/1
  # PATCH/PUT /videos/1.json
  def update
    respond_to do |format|
      if @video.update(video_params)
        format.html { redirect_to @video, notice: 'Video was successfully updated.' }
        format.json { render :show, status: :ok, location: @video }
      else
        format.html { render :edit }
        format.json { render json: @video.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /videos/1
  # DELETE /videos/1.json
  def destroy
    @stream = Stream.friendly.find(params[:stream_id])
    @video = @stream.videos.find(params[:id])


    @video.destroy
    respond_to do |format|
      format.html { redirect_to edit_stream_path(@stream), notice: 'Video was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_video
      @video = Video.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def video_params
      params.require(:video).permit(:url, :name, :playcount, :length)
    end
end
