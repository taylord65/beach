class StreamsController < ApplicationController
  before_action :set_stream, only: [:show, :edit, :update, :destroy]

  # GET /streams
  # GET /streams.json
  def index
    @streams = Stream.all
  end

  # GET /streams/1
  # GET /streams/1.json
  
  def setplaylist
    @stream = Stream.friendly.find(params[:id])
    @stream.reprogrammed_at = Time.now.to_i
    @stream.save
  end
  
  
  def show
       
       if (Stream.friendly.find(params[:id]).videos.first).nil? 
         gon.videoidcurrent = ['8tPnX7OPo0Q']
         #blank video appears in watch if there are no videos in the database 
       else
         #on page load
         #Place all of the video ids into an array
         ids = Stream.friendly.find(params[:id]).videos.pluck(:video_id)
         #can use ids.shuffle to randomize the array
         
         #Place all of the video lengths into an array
         lengths = Stream.friendly.find(params[:id]).videos.pluck(:length)
         
         #These should stay here 
         gon.totalfootage = lengths.inject(:+)
         gon.videolengths = lengths
         gon.videoids = ids
         gon.starttime = (Time.now.to_i - @stream.updated_at.to_i)
       end
  end
   
  

  # GET /streams/new
  def new
    @stream = Stream.new
  end

  # GET /streams/1/edit
  def edit

  end
  
  def watch
    @streams = Stream.all
  end


  # POST /streams
  # POST /streams.json
  def create
    @stream = Stream.new(stream_params)

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
    respond_to do |format|
      format.html { redirect_to streams_url, notice: 'Stream was successfully destroyed.' }
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
