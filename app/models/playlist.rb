require 'open-uri'

class Playlist < ActiveRecord::Base
  belongs_to :stream
  
  validates :url, :format => {
      :with    => %r{www.youtube.com/playlist}i,
      :message => 'must be a youtube playlist url.' }
      
      def playlistconverturl(url)
          if url.include? "www.youtube.com/playlist?list=" 

          regex = /(?:.be\/|\/playlist\?list=|\/(?=p\/))([\w\/\-]+)/
          playlist_id = url.match(regex)[1]
          playlist_id
        end  
      end
      
      
      def get_youtube_playlist_title(playlist_id)
        title = JSON.parse(open("http://gdata.youtube.com/feeds/api/playlists/#{self.playlist_id}?v=2&alt=jsonc").read)['data']['title']
        title
      end

end
