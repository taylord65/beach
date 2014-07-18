require 'open-uri'
require 'date'


class Video < ActiveRecord::Base
  belongs_to :stream
 
  
  validates :url, :format => {
      :with    => %r{www.youtube.com/watch}i,
      :message => 'must be a youtube video url. Accepted Formats: ' }

      def get_youtube_video_duration(video_id)
        length = JSON.parse(open("http://gdata.youtube.com/feeds/api/videos/#{self.video_id}?v=2&alt=jsonc").read)['data']['duration']
        length
      end
      
      def get_youtube_video_name(video_id)
        name = JSON.parse(open("http://gdata.youtube.com/feeds/api/videos/#{self.video_id}?v=2&alt=jsonc").read)['data']['title']
        name
      end
      
      def get_youtube_video_date(video_id)
        #single video submissions are given a y_date_added of the time at submission 
        date = Time.now
        date
      end
      
    def converturl(url)
        if url.include? "www.youtube.com/watch?v=" 
        #converts a url into a video id

        regex = /(?:.be\/|\/watch\?v=|\/(?=p\/))([\w\/\-]+)/
        video_id = url.match(regex)[1]
        video_id
      end  
    end
    

end
