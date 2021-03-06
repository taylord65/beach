class ChannelsController < ApplicationController
  before_action :set_channel, only: [:show, :edit, :update, :destroy]
  require 'open-uri'
  require 'openssl'

  # GET /channels
  # GET /channels.json
  def index
    
    @stream = Stream.friendly.find(params[:stream_id]) 
    
    if user_signed_in?
    @addkey = @stream.admins.find_by admin_key: current_user.id    
    end
    
    @channels = Channel.all
    
    
  end

  # GET /channels/1
  # GET /channels/1.json
  def show
  end

  # GET /channels/new
  def new
    @channel = Channel.new
  end

  # GET /channels/1/edit
  def edit
  end

  # POST /channels
  # POST /channels.json
  def create
    
    @stream = Stream.friendly.find(params[:stream_id]) 
    @channel = @stream.channels.find_or_initialize_by(channel_params)
    
    if @channel.valid?
    @channel.doc = @channel.getdoc(@channel.url)

    doc = Nokogiri::HTML(open(@channel.doc))
    
    a = doc.at('title').content
    a.slice! " - YouTube"
    @channel.title = a
    
    @stream.delay.download_channel_videos(@channel.url)
        
    end 

    respond_to do |format|
      if @channel.save
        format.html { redirect_to edit_stream_path(@stream), notice: '✓ Channel is being connected to stream' }
        format.json { render :show, status: :created, location: @channel }
      else
        format.html { render :new }
        format.json { render json: @channel.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /channels/1
  # PATCH/PUT /channels/1.json
  def update
    respond_to do |format|
      if @channel.update(channel_params)
        format.html { redirect_to @channel, notice: '✓ Channel was successfully updated' }
        format.json { render :show, status: :ok, location: @channel }
      else
        format.html { render :edit }
        format.json { render json: @channel.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /channels/1
  # DELETE /channels/1.json
  def destroy
    @stream = Stream.friendly.find(params[:stream_id]) 
    
    videos_from_channel = @stream.videos.where(:pid => @channel.url )
    videos_from_channel.destroy_all
    
    @channel.destroy
    
    respond_to do |format|
      format.html { redirect_to edit_stream_path(@stream), notice: '✓ Channel was removed' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_channel
      @channel = Channel.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def channel_params
      params.require(:channel).permit(:url, :title)
    end
end
