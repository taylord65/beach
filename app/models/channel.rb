class Channel < ActiveRecord::Base
  
  belongs_to :stream
  
  validates :url, :format => {:with => %r{youtube.com(/channel|/user)}, :message => 'must be a youtube channel or user url.' }
       
end
