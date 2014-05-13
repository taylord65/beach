class Video < ActiveRecord::Base
  belongs_to :stream
  #need to validate the correct format "www.youtube.com" or whatever
  
 # validates :url, :uniqueness => true
 # need to validate only for the specific stream 
  
#NEED TO VALIDATE youtube url  
  validates :url, :format => {
      :with    => %r{https://www.youtube.com/}i,
      :message => 'must be a https youtube video.' }
      
    def converturl(url)
        if url.include? "https://www.youtube.com/" 
        #converts a url into a video id

        regex = /(?:.be\/|\/watch\?v=|\/(?=p\/))([\w\/\-]+)/
        video_id = url.match(regex)[1]
        video_id
      end  
    end
    
  
  
end
