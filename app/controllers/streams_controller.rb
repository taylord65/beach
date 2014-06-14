class StreamsController < ApplicationController
  before_action :set_stream, only: [:show, :edit, :update, :destroy]
  require 'open-uri'

  # GET /streams
  # GET /streams.json
  def index
    @streams = Stream.search(params)
    
    if user_signed_in?
    @subscriptions = current_user.subscriptions

    end
    
    render :layout => 'splashlayout'
  end
  
  def filter
    #Deletes every video in the playlists and user channels and rescrapes the sources for new content
    #This is takes a lot of server computation time, it would be better if there was a loading bar that displays the process's progress
    
    #still need a way to filter out content that has been in the stream for a long time such as individual videos and playlists and channels that dont get updated often or at all
    
    @stream = Stream.friendly.find(params[:id])
    
    @stream.playlists.each do |playlist|
      
      videos_from_playlist = @stream.videos.where(:pid => playlist.playlist_id )
      videos_from_playlist.destroy_all
      
       doc = Nokogiri::HTML(open("https://www.youtube.com/playlist?list=#{playlist.playlist_id}"))

          doc.css("[data-video-id]").each do |el|
            begin
            @scraped_id = el.attr('data-video-id')
     video = @stream.videos.find_or_create_by( video_id: @scraped_id, 
                                               pid: playlist.playlist_id, 
                                               length: JSON.parse(open("http://gdata.youtube.com/feeds/api/videos/#{@scraped_id}?v=2&alt=jsonc").read)['data']['duration'],
                                               name:  JSON.parse(open("http://gdata.youtube.com/feeds/api/videos/#{@scraped_id}?v=2&alt=jsonc").read)['data']['title'],
                                               url: "https://www.youtube.com/watch?v=" + "#{@scraped_id}"
                                              )
            rescue OpenURI::HTTPError
                next
            end

          end
      
    end # end playlist loop
    
    @stream.channels.each do |channel|
    
      videos_from_channel = @stream.videos.where(:pid => channel.url )
      videos_from_channel.destroy_all
      
      doc = Nokogiri::HTML(open(channel.doc))
      
      doc.css("[data-video-ids]").each do |el|
            begin
            @scraped_id = el.attr('data-video-ids')
     video = @stream.videos.find_or_create_by( video_id: @scraped_id, 
                                               pid: channel.url, 
                                               length: JSON.parse(open("http://gdata.youtube.com/feeds/api/videos/#{@scraped_id}?v=2&alt=jsonc").read)['data']['duration'],
                                               name:  JSON.parse(open("http://gdata.youtube.com/feeds/api/videos/#{@scraped_id}?v=2&alt=jsonc").read)['data']['title'],
                                               url: "https://www.youtube.com/watch?v=" + "#{@scraped_id}"
                                              )
            rescue OpenURI::HTTPError
                next
            end

      end
    
    end # end channel loop
    
    redirect_to edit_stream_path(@stream) , notice: 'Stream was successfully filtered.'   
  end
  
  def watchsub
    subscription_title = params[:title]
    @stream = Stream.friendly.find_by title: subscription_title
    #need to route to page doesnt exist 
    unless @stream.nil?
      redirect_to stream_path(@stream)
    end
    
  end

  # GET /streams/1
  # GET /streams/1.json
  def subscribe
    
    @stream = Stream.friendly.find(params[:id])
    
    if current_user.subscriptions.where(title: @stream.title).blank?
    @stream.increment(:subs, by = 1)
    @stream.save
    
    @subscription = current_user.subscriptions.create(params[:subscription])
    @subscription.title = @stream.title
    @subscription.save
    redirect_to stream_path(@stream)
    else
      @subscription = current_user.subscriptions.find_by title: @stream.title
      @subscription.destroy
      @stream.decrement(:subs, by = 1)
      @stream.save
      redirect_to stream_path(@stream)      
    end
  end
  
  def setvideos
     @stream = Stream.friendly.find(params[:id])
     @stream.reprogrammed_at = Time.now

     @ids, @lengths = Stream.friendly.find(params[:id]).videos.pluck(:video_id, :length).shuffle.transpose
     @stream.totallength = Stream.friendly.find(params[:id]).videos.pluck(:length).inject(:+)     
     @stream.idlist = @ids
     @stream.lengthlist = @lengths
     @stream.save
  redirect_to edit_stream_path(@stream), notice: 'Stream was successfully programmed.'
   end
  
  def show

    if user_signed_in?
      
      if current_user.subscriptions.where(title: @stream.title).blank?
        @buttontext = "Subscribe"
      else
        @buttontext = "Unsubscribe"
      end  
      
      
    @stream = Stream.friendly.find(params[:id])
    @addkey = @stream.admins.find_by admin_key: current_user.id    
    @subscriptions = current_user.subscriptions
    end
       
       if (Stream.friendly.find(params[:id]).videos.first).nil? 
         gon.videoidcurrent = ['8tPnX7OPo0Q']
         #blank video appears in watch if there are no videos in the database 
       else
         @stream = Stream.friendly.find(params[:id])
         
         gon.videolengths = @stream.lengthlist
         gon.videoids = @stream.idlist
         gon.totalfootage = @stream.totallength
         
         gon.starttime = (Time.now.to_i - @stream.reprogrammed_at.to_i)
       end
  end

  # GET /streams/new
  def new
    
    @stream = Stream.new
    render :layout => 'devise'
    
  end

  # GET /streams/1/edit
  def edit  
    if user_signed_in?
    @stream = Stream.friendly.find(params[:id])
    @addkey = @stream.admins.find_by admin_key: current_user.id
    end
    render :layout => 'editlayout'
  end
  
  def watch
    @streams = Stream.all
  end


  # POST /streams
  # POST /streams.json
  def create
    @stream = Stream.new(stream_params)
    @stream.reprogrammed_at = Time.now
    @stream.lengthlist = [6399]
    @stream.idlist = ['8tPnX7OPo0Q']
    @stream.totallength = 6399
    
    respond_to do |format|
      if @stream.save
        
        @admin = @stream.admins.create(params[:admin])
        @admin.admin_key = current_user.id
        @admin.save
        
        format.html { redirect_to edit_stream_path(@stream), notice: 'Stream was successfully created.' }
        format.json { render :show, status: :created, location: @stream }
      else
        format.html { render :new }
        format.json { render json: @stream.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /streams/1
  # PATCH/PUT /streams/1.json
  def update
    respond_to do |format|
      if @stream.update(stream_params)
        format.html { redirect_to edit_stream_path(@stream), notice: 'Stream was successfully updated.' }
        format.json { render :show, status: :ok, location: @stream }
      else
        format.html { render :edit }
        format.json { render json: @stream.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /streams/1
  # DELETE /streams/1.json
  def destroy
    @stream.destroy
    @stream.tire.update_index
  #  system "rake environment tire:import CLASS=Stream FORCE=true"
    
    respond_to do |format|
      format.html { redirect_to splash_path }
      #, notice: 'Stream was successfully destroyed.'
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_stream
      @stream = Stream.friendly.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def stream_params
      params.require(:stream).permit(:title, :description)
    end
end
