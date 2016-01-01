require 'open-uri'
require 'json'
require 'openssl'

OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE

class Stream < ActiveRecord::Base
  has_many :videos, :dependent => :destroy
  has_many :admins, :dependent => :destroy
  has_many :playlists, :dependent => :destroy
  has_many :channels, :dependent => :destroy
  validates :title, :description, :presence => true
  validates :title, :uniqueness => {:case_sensitive => false}
  validates :title, :format => { with: /^[a-zA-Z0-9]*$/ , :multiline => true, :message => 'cannot contain special characters, only letters and numbers.' }
  validates :title, :format => { without: /\s/ , :message => 'cannot have spaces.' }
  
  validates :title, length: {in: 2..17, :message => ' must be between 2 and 17 characters.' }
  validates :description, length: {in: 0..400, :message => ' cannot exceed 200 characters.' }
  
  extend FriendlyId
  friendly_id :title
  
  include Tire::Model::Search
  include Tire::Model::Callbacks
    
  def self.search(params)    
    tire.search(load: true) do
      query { string params[:query], default_operator: "AND" } if params[:query].present?
      size 100
    end
  end
  
   def download_playlist_videos(list_id)
      
      doc = Nokogiri::HTML(open("https://www.youtube.com/playlist?list=#{list_id}"))
      
           doc.css("[data-video-id]").each do |el|
             begin
             @scraped_id = el.attr('data-video-id')
             
             if self.videos.where(video_id: @scraped_id).blank?

             length = get_youtube_video_duration(@scraped_id)

      video = self.videos.find_or_create_by( video_id: @scraped_id, 
                                                pid: list_id, 
                                                length: length,
                                                name:  JSON.parse(open("https://www.googleapis.com/youtube/v3/videos?id=#{@scraped_id}&key=AIzaSyBD1bw3Tt2UX-kc_HgDTF2nKxyGfjcfIZ4&fields=items(snippet(title))&part=snippet").read)["items"][0]["snippet"]["title"],
                                                url: "https://www.youtube.com/watch?v=" + "#{@scraped_id}",
                                                y_date_added: Time.now                                       
                                               )
            else
                next
            end
                                                                                            
             rescue OpenURI::HTTPError
                 next
             end

           end
      
      
    end
    
    
    def download_channel_videos(url)
      
      if url =~ /channel/
        path = URI.parse(url).path
        id = File.basename(path)
        channel_page = Nokogiri::HTML(open("https://www.youtube.com/channel/#{id}/videos?sort=dd&flow=list&view=0"))
      else
        path = URI.parse(url).path
        id = File.basename(path)
        channel_page = Nokogiri::HTML(open("https://www.youtube.com/user/#{id}/videos?sort=dd&flow=list&view=0"))
      end
      
                  
      channel_page.css("[data-video-ids]").each do |el|
            begin
            @scraped_id = el.attr('data-video-ids') 

            if self.videos.where(video_id: @scraped_id).blank?  

            length = get_youtube_video_duration(@scraped_id)     

     video = self.videos.find_or_create_by( video_id: @scraped_id, 
                                               pid: url, 
                                               length: length,
                                               name:  JSON.parse(open("https://www.googleapis.com/youtube/v3/videos?id=#{@scraped_id}&key=AIzaSyBD1bw3Tt2UX-kc_HgDTF2nKxyGfjcfIZ4&fields=items(snippet(title))&part=snippet").read)["items"][0]["snippet"]["title"],
                                               url: "https://www.youtube.com/watch?v=" + "#{@scraped_id}",
                                               y_date_added: JSON.parse(open("https://www.googleapis.com/youtube/v3/videos?id=#{@scraped_id}&key=AIzaSyBD1bw3Tt2UX-kc_HgDTF2nKxyGfjcfIZ4&fields=items(snippet(publishedAt))&part=snippet").read)["items"][0]["snippet"]["publishedAt"]                                     
                                              )  
            else
                next
            end     

            rescue OpenURI::HTTPError
                next
            end

      end #end do
    
    end #end download_channel_videos

    def get_youtube_video_duration(video_id)
      duration = JSON.parse(open("https://www.googleapis.com/youtube/v3/videos?id=#{video_id}&key=AIzaSyBD1bw3Tt2UX-kc_HgDTF2nKxyGfjcfIZ4&fields=items(contentDetails(duration))&part=contentDetails").read)["items"][0]["contentDetails"]["duration"]
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

end
