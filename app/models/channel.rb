class Channel < ActiveRecord::Base
  require 'uri'
  
  belongs_to :stream
  
  validates :url, :format => {:with => %r{youtube.com(/channel|/user)}, :message => 'must be a youtube channel or user url.' }
  
  
  def getdoc(url)
    
    if url =~ /channel/
      path = URI.parse(url).path
      id = File.basename(path)
      
      doc = "https://www.youtube.com/channel/#{id}/videos"
      doc
    else
      path = URI.parse(url).path
      id = File.basename(path)
      
      doc = "https://www.youtube.com/user/#{id}/videos"
      doc
    
    end
    
  end
  
       
end
