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
    
  end
  
  def watchsub
    subscription_title = params[:title]
    @stream = Stream.friendly.find_by title: subscription_title
    if @stream.nil?
     subscription = current_user.subscriptions.find_by title: subscription_title
     subscription.destroy
     redirect_to streamnotfound_pagedoesntexist_path
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
  
  
  def show
    @stream = Stream.friendly.find(params[:id])
    gon.end_of_stream = @stream.totallength + @stream.reprogrammed_at.to_i
    
    if user_signed_in?
      
      if current_user.subscriptions.where(title: @stream.title).blank?
        @buttontext = "subscribe"
      else
        @buttontext = "unsubscribe"
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
  end

  def edit  
    @stream = Stream.friendly.find(params[:id])
    if user_signed_in?
    @addkey = @stream.admins.find_by admin_key: current_user.id
    end
  end
  

  def create
    @stream = Stream.new(stream_params)
    @stream.reprogrammed_at = Time.now
    @stream.lengthlist = [1]
    @stream.idlist = ['8tPnX7OPo0Q']
    @stream.totallength = 1
    #ready for filter at next cycle
    @stream.increment(:subs, by = 1)
    
    respond_to do |format|
      if @stream.save
        
        @admin = @stream.admins.create(params[:admin])
        @admin.admin_key = current_user.id
        @admin.save

        @subscription = current_user.subscriptions.create(params[:subscription])
        @subscription.title = @stream.title
        @subscription.save
        
        format.html { redirect_to edit_stream_path(@stream), notice: '✓ Stream Created. Add videos and sources to build the stream' }
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
        format.html { redirect_to edit_stream_path(@stream), notice: '✓ Stream was successfully updated.' }
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
    subscription = current_user.subscriptions.find_by title: @stream.title
    subscription.destroy
    
    @stream.destroy
    @stream.tire.update_index
  #  system "rake environment tire:import CLASS=Stream FORCE=true"
    
    respond_to do |format|
      format.html { redirect_to streamnotfound_pagedoesntexist_path }
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
