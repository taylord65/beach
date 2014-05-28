class StreamsController < ApplicationController
  before_action :set_stream, only: [:show, :edit, :update, :destroy]

  # GET /streams
  # GET /streams.json
  def index
    
    @streams = Stream.search(params)
    
    render :layout => 'splashlayout'

  end

  # GET /streams/1
  # GET /streams/1.json
  
  
  def show
       
       if (Stream.friendly.find(params[:id]).videos.first).nil? 
         gon.videoidcurrent = ['8tPnX7OPo0Q']
         #blank video appears in watch if there are no videos in the database 
       else
         @stream = Stream.friendly.find(params[:id])
         
         def setvideos
           @stream = Stream.friendly.find(params[:id])
           @stream.reprogrammed_at = Time.now
           
           #SET THE STREAM PLAYLIST
           @ids, @lengths = Stream.friendly.find(params[:id]).videos.pluck(:video_id, :length).shuffle.transpose
           @stream.idlist = @ids
           @stream.lengthlist = @lengths
           @stream.save
           redirect_to edit_stream_path(@stream), notice: 'Stream was successfully programmed.'
         end
         
         gon.videolengths = @stream.lengthlist
         gon.videoids = @stream.idlist
         gon.totalfootage = @stream.totallength
         
         #the time is arbitrary 
         gon.starttime = (Time.now.to_i - @stream.reprogrammed_at.to_i)
       end
  end

  def subscribe
    @stream = Stream.friendly.find(params[:id])
    @stream.increment(:subs, by = 1)
    
    @stream.save
    redirect_to stream_path(@stream)
  end


  # GET /streams/new
  def new
    
    @stream = Stream.new
    render :layout => 'devise'
    
  end

  # GET /streams/1/edit
  def edit
    @stream.totallength = Stream.friendly.find(params[:id]).videos.pluck(:length).inject(:+)
    @stream.save
     
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
    respond_to do |format|
      if @stream.save
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
