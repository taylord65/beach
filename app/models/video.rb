require 'open-uri'
require 'json'
require 'openssl'

OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE

class Video < ActiveRecord::Base
  belongs_to :stream
  
  validates :url, :format => {
      :with    => %r{www.youtube.com/watch}i,
      :message => 'must be a youtube video url' }

      def get_youtube_video_duration(video_id)
        duration = JSON.parse(open("https://www.googleapis.com/youtube/v3/videos?id=#{self.video_id}&key=AIzaSyBD1bw3Tt2UX-kc_HgDTF2nKxyGfjcfIZ4&fields=items(contentDetails(duration))&part=contentDetails").read)["items"][0]["contentDetails"]["duration"]
        duration.slice! "PT"
        length = 0

        if duration.include? "H"
          copy = duration
          copy = copy.slice(0..(copy.index('H')))
          copy.slice! "H"
          hours = copy.to_i
          seconds = hours*3600
          length += seconds
        end  

        if duration.include? "M"
          copy = duration
          if duration.include? "H"
            copy = copy.slice(0..(copy.index('M')))
            copy.slice!(0..(copy.index('H'))) 
            copy.slice! "H"
            copy.slice! "M"
            minutes = copy.to_i
            seconds = minutes*60
            length += seconds
          else
            copy = copy.slice(0..(copy.index('M')))
            copy.slice! "M"
            minutes = copy.to_i
            seconds = minutes*60
            length += seconds
          end
        end

        if duration.include? "S"
          copy = duration
          if duration.include? "M"
            copy.slice!(0..(copy.index('M')))
            copy.slice! "S"
            seconds = copy.to_i
            length += seconds
          elsif duration.include? "H"
            copy.slice!(0..(copy.index('H')))
            copy.slice! "S"
            seconds = copy.to_i
            length += seconds
          else
            copy.slice! "S"
            seconds = copy.to_i
            length += seconds      
          end
        end
      end
      
      def get_youtube_video_name(video_id)
        name = JSON.parse(open("https://www.googleapis.com/youtube/v3/videos?id=#{self.video_id}&key=AIzaSyBD1bw3Tt2UX-kc_HgDTF2nKxyGfjcfIZ4&fields=items(snippet(title))&part=snippet").read)["items"][0]["snippet"]["title"]
        name
      end
      
      def get_youtube_video_date(video_id)
        date = Time.now
        date
      end
      
    def converturl(url)
        if url.include? "https://www.youtube.com/watch?v=" 
        #converts a url into a video id

        regex = /(?:.be\/|\/watch\?v=|\/(?=p\/))([\w\/\-]+)/
        video_id = url.match(regex)[1]
        video_id
      end  
    end
    

end
