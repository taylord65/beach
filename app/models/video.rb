require 'open-uri'

class Video < ActiveRecord::Base
  belongs_to :stream
  #need to validate the correct format "www.youtube.com" or whatever
  
 # validates :url, :uniqueness => true
 # need to validate only for the specific stream 
  
#NEED TO VALIDATE youtube url  
  validates :url, :format => {
      :with    => %r{http://www.youtube.com/}i,
      :message => 'must be a https youtube video.' }
      
      

      def get_youtube_video_duration(video_id)
        length = JSON.parse(open("http://gdata.youtube.com/feeds/api/videos/#{self.video_id}?v=2&alt=jsonc").read)['data']['duration']
        length
      end
      
      def get_youtube_video_name(video_id)
        name = JSON.parse(open("http://gdata.youtube.com/feeds/api/videos/#{self.video_id}?v=2&alt=jsonc").read)['data']['title']
        name
      end
      
    def converturl(url)
        if url.include? "www.youtube.com/" 
        #converts a url into a video id

        regex = /(?:.be\/|\/watch\?v=|\/(?=p\/))([\w\/\-]+)/
        video_id = url.match(regex)[1]
        video_id
      end  
    end
    
      
    
    
  
end
