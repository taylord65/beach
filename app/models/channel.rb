class Channel < ActiveRecord::Base
  require 'uri'
  require 'open-uri'
  require 'openssl'
  
  belongs_to :stream
  
  validates :url, :format => {:with => %r{youtube.com(/channel|/user)}, :message => 'must be a youtube channel or user url. Example formats: http://www.youtube.com/user/XXXXXXX or http://www.youtube.com/channel/XXXXXXX' }
  
  
  def getdoc(url)
    
    if url =~ /channel/

      if url.include? "/videos"
        url.slice! "/videos"
      end

      path = URI.parse(url).path
      id = File.basename(path)
      
      doc = "https://www.youtube.com/channel/#{id}/videos?sort=dd&flow=list&view=0"
      doc
    else
      if url.include? "/videos"
        url.slice! "/videos"
      end

      path = URI.parse(url).path
      id = File.basename(path)
      
      doc = "https://www.youtube.com/user/#{id}/videos?sort=dd&flow=list&view=0"
      doc
    
    end
    
  end
  
       
end
