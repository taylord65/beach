class Stream < ActiveRecord::Base
  has_many :videos, :dependent => :destroy
  has_many :admins, :dependent => :destroy
  has_many :playlists, :dependent => :destroy
  has_many :channels, :dependent => :destroy
  validates :title, :description, :presence => true
  validates :title, :uniqueness => {:case_sensitive => false}
  validates :title, :format => { with: /^[a-zA-Z0-9]*$/ , :multiline => true, :message => 'cannot contain special characters, only letters and numbers.' }
  validates :title, :format => { without: /\s/ , :message => 'cannot have spaces.' }
  
  validates :title, length: {in: 2..20, :message => ' must be between 2 and 20 characters.' }
  validates :description, length: {in: 0..400, :message => ' cannot exceed 200 characters.' }
  
  extend FriendlyId
  friendly_id :title
  
  include Tire::Model::Search
  include Tire::Model::Callbacks
    
  def self.search(params)    
    tire.search(load: true) do
      query { string params[:query], default_operator: "AND" } if params[:query].present?
    end
  end
  
  
  
   def download_playlist_videos(list_id)
     
     require 'open-uri'
      
      doc = Nokogiri::HTML(open("https://www.youtube.com/playlist?list=#{list_id}"))
      
           doc.css("[data-video-id]").each do |el|
             begin
             @scraped_id = el.attr('data-video-id')
             
             if self.videos.where(video_id: @scraped_id).blank?

             @date = JSON.parse(open("http://gdata.youtube.com/feeds/api/videos/#{@scraped_id}?v=2&alt=jsonc").read)['data']['uploaded']
             @datestamp = @date.split("T").first        

      video = self.videos.find_or_create_by( video_id: @scraped_id, 
                                                pid: list_id, 
                                                length: JSON.parse(open("http://gdata.youtube.com/feeds/api/videos/#{@scraped_id}?v=2&alt=jsonc").read)['data']['duration'],
                                                name:  JSON.parse(open("http://gdata.youtube.com/feeds/api/videos/#{@scraped_id}?v=2&alt=jsonc").read)['data']['title'],
                                                url: "https://www.youtube.com/watch?v=" + "#{@scraped_id}",
                                                y_date_added: @datestamp                                           
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
      #could also get the most popular of all time from each channel
      
      require 'open-uri'
      
      if url =~ /channel/
        path = URI.parse(url).path
        id = File.basename(path)
        channel_page = Nokogiri::HTML(open("https://www.youtube.com/channel/#{id}/videos?sort=dd&flow=list&view=0"))
      else
        path = URI.parse(url).path
        id = File.basename(path)
        channel_page = Nokogiri::HTML(open("https://www.youtube.com/user/#{id}/videos?sort=dd&flow=list&view=0"))
      end
      
                  
      channel_page.css("[data-video-ids]").take(10).each do |el|
            begin
            @scraped_id = el.attr('data-video-ids') 

            if self.videos.where(video_id: @scraped_id).blank?

            @date = JSON.parse(open("http://gdata.youtube.com/feeds/api/videos/#{@scraped_id}?v=2&alt=jsonc").read)['data']['uploaded']
            @datestamp = @date.split("T").first          

     video = self.videos.find_or_create_by( video_id: @scraped_id, 
                                               pid: url, 
                                               length: JSON.parse(open("http://gdata.youtube.com/feeds/api/videos/#{@scraped_id}?v=2&alt=jsonc").read)['data']['duration'],
                                               name:  JSON.parse(open("http://gdata.youtube.com/feeds/api/videos/#{@scraped_id}?v=2&alt=jsonc").read)['data']['title'],
                                               url: "https://www.youtube.com/watch?v=" + "#{@scraped_id}",
                                               y_date_added: @datestamp                                           
                                              )  
                      
            else
                next
            end     

            rescue OpenURI::HTTPError
                next
            end

      end #end do
    
    end #end download_channel_videos

end
