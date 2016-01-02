require 'open-uri'

class Playlist < ActiveRecord::Base
  belongs_to :stream
  
  validates :url, :format => {
      :with    => %r{www.youtube.com/playlist}i,
      :message => 'must be a youtube playlist url. Example format http://www.youtube.com/playlist?list=XXXXXXXXXXXX' }
      
      def playlistconverturl(url)
          if url.include? "www.youtube.com/playlist?list=" 

          regex = /(?:.be\/|\/playlist\?list=|\/(?=p\/))([\w\/\-]+)/
          playlist_id = url.match(regex)[1]
          playlist_id
        end  
      end
      
      
      def get_youtube_playlist_title(playlist_id)
        title = JSON.parse(open("https://www.googleapis.com/youtube/v3/playlists?id=#{self.playlist_id}&key=AIzaSyBD1bw3Tt2UX-kc_HgDTF2nKxyGfjcfIZ4&fields=items(snippet(title))&part=snippet").read)["items"][0]["snippet"]["title"]
        title
      end
      
      

end
