class StreamsController < ApplicationController
  before_action :set_stream, only: [:show, :edit, :update, :destroy]
  require 'open-uri'

  # GET /streams
  # GET /streams.json
  def index
    @streams = Stream.search(params)  
    #@streams = params[:search] ? Stream.search(params[:search]) : Stream.none    
    
    if user_signed_in?
    @subscriptions = current_user.subscriptions
    end
    
    render :layout => 'splashlayout'
  end
  
  def filter
    #still need a way to filter out content that has been in the stream for a long time such as individual videos and playlists and channels that dont get updated often or at all
    @stream = Stream.friendly.find(params[:id])
    
    @stream.playlists.each do |playlist|
      
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
    
      #checks the channel and only gets new videos
      #should remove old videos 
    
      #videos_from_channel = @stream.videos.where(:pid => channel.url )
      #videos_from_channel.destroy_all  
    
    @stream.channels.each do |channel|
      #vid_total_added = 0
      doc = Nokogiri::HTML(open(channel.doc))
      
      doc.css("[data-video-ids]").each do |el|
            begin
            @scraped_id = el.attr('data-video-ids')
            
            if @stream.videos.where(video_id: @scraped_id).blank?
              
              video = @stream.videos.find_or_create_by( video_id: @scraped_id, 
                                                        pid: channel.url, 
                                                        length: JSON.parse(open("http://gdata.youtube.com/feeds/api/videos/#{@scraped_id}?v=2&alt=jsonc").read)['data']['duration'],
                                                        name:  JSON.parse(open("http://gdata.youtube.com/feeds/api/videos/#{@scraped_id}?v=2&alt=jsonc").read)['data']['title'],
                                                        url: "https://www.youtube.com/watch?v=" + "#{@scraped_id}"
                                                       ) 
              #vid_total_added += 1                                                                            
             else
                break
             end                                        
                                                    
            rescue OpenURI::HTTPError
                next
            end
            #remove vid_total_added amount of videos from the stream, the oldest ones, if the total length is over the stable footage limit, maybe use while over remove them
            #you dont want to remove old to the stream but new to youtube
      end
    
    end # end channel loop
    
    redirect_to edit_stream_path(@stream) , notice: 'Stream was successfully filtered.'   
  end
  
  def watchsub
    subscription_title = params[:title]
    @stream = Stream.friendly.find_by title: subscription_title
    if @stream.nil?
     #need to route to page doesnt exist with a back link that refreshes
     subscription = current_user.subscriptions.find_by title: subscription_title
     subscription.destroy
    else
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
      addkey = @stream.admins.find_by admin_key: current_user.id
      
      if addkey.nil?
        #user is not the admin
        @subscription = current_user.subscriptions.find_by title: @stream.title
        @subscription.destroy
        @stream.decrement(:subs, by = 1)
        @stream.save
        redirect_to stream_path(@stream)
      else
        #you can't unsubscribe if you are the admin
        redirect_to stream_path(@stream)        
      end

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
    @stream = Stream.friendly.find(params[:id])

    if user_signed_in?
      
      if current_user.subscriptions.where(title: @stream.title).blank?
        @buttontext = "Subscribe"
      else
        @buttontext = "Unsubscribe"
      end 
      
    @addkey = @stream.admins.find_by admin_key: current_user.id    
    @subscriptions = current_user.subscriptions
    end #end user signed in
       
       if (Stream.friendly.find(params[:id]).videos.first).nil? 
         gon.playlist = ['8tPnX7OPo0Q']
         gon.s_index = 0
         gon.s_time = 0
         #blank video appears in watch if there are no videos in the database 
       else         
         videolengths = @stream.lengthlist
         videoids = @stream.idlist
         totalfootage = @stream.totallength
         starttime = (Time.now.to_i - @stream.reprogrammed_at.to_i)
         
         if starttime < videolengths[0] 
           #The time is less than the length of the first video. Play first at the time.
           gon.playlist = videoids
           gon.s_index = 0
           gon.s_time = starttime
         else
           
           if starttime > totalfootage
             while starttime > totalfootage
               starttime -= totalfootage
             end
           end
           
           runningtotal = 0
           
           videoids.each_index do |i|
             
              runningtotal += videolengths[i]
              
              if runningtotal >= starttime
                total = 0
                k = 0
                
                while k < i
                  total += videolengths[k]
                  k += 1
                end
                
                gon.playlist = videoids
                gon.s_index = i
                gon.s_time = starttime - total

                break
                
              end #end if
           end #end do loop
         end # end else
       end #end else
  end # end show

  def new
    @stream = Stream.new
    render :layout => 'devise'
  end

  def edit  
    if user_signed_in?
    @stream = Stream.friendly.find(params[:id])
    @addkey = @stream.admins.find_by admin_key: current_user.id
    end
    render :layout => 'editlayout'
  end
  

  def create
    @stream = Stream.new(stream_params)
    @stream.reprogrammed_at = Time.now
    @stream.lengthlist = [6399]
    @stream.idlist = ['8tPnX7OPo0Q']
    @stream.totallength = 6399
    @stream.increment(:subs, by = 1)
    
    respond_to do |format|
      if @stream.save
        
        @admin = @stream.admins.create(params[:admin])
        @admin.admin_key = current_user.id
        @admin.save

        @subscription = current_user.subscriptions.create(params[:subscription])
        @subscription.title = @stream.title
        @subscription.save
        
        format.html { redirect_to edit_stream_path(@stream), notice: 'Stream Created. Add videos and sources to build the stream' }
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
      format.html { redirect_to streams_path }
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
