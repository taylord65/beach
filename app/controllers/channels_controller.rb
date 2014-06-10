class ChannelsController < ApplicationController
  before_action :set_channel, only: [:show, :edit, :update, :destroy]
  require 'open-uri'

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
       
      #parse url for either user name or channel id through a model method. return either the channel id or the user name into a @channel.doc variable
      #open the channel.doc string for vid loop and to scrape the <title> for @channel.title 

      doc = Nokogiri::HTML(open("https://www.youtube.com/channel/#{     }/videos"))

        doc.css("[data-video-ids]").each do |el|
          begin
          @scraped_id = el.attr('data-video-ids')
   video = @stream.videos.find_or_create_by( video_id: @scraped_id, 
                                             pid: @playlist.playlist_id, 
                                             length: JSON.parse(open("http://gdata.youtube.com/feeds/api/videos/#{@scraped_id}?v=2&alt=jsonc").read)['data']['duration'],
                                             name:  JSON.parse(open("http://gdata.youtube.com/feeds/api/videos/#{@scraped_id}?v=2&alt=jsonc").read)['data']['title'],
                                             url: "https://www.youtube.com/watch?v=" + "#{@scraped_id}"
                                            )
          rescue OpenURI::HTTPError
              next
          end
        end
      end

    respond_to do |format|
      if @channel.save
        format.html { redirect_to @channel, notice: 'Channel was successfully created.' }
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
        format.html { redirect_to @channel, notice: 'Channel was successfully updated.' }
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
    @channel.destroy
    respond_to do |format|
      format.html { redirect_to channels_url, notice: 'Channel was successfully destroyed.' }
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
