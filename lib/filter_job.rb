class FilterJob
  
  require 'open-uri'
  

def perform
  
  timenow = Time.now.to_i
  
  Stream.all.each do |stream|
    
if stream.videos.first.present? 
        
if timenow >= stream.totallength + stream.reprogrammed_at.to_i    
=begin      
####################################################################################       
  stream.playlists.each do |playlist|
    
     doc = Nokogiri::HTML(open("https://www.youtube.com/playlist?list=#{playlist.playlist_id}"))

        doc.css("[data-video-id]").each do |el|
          begin
          @scraped_id = el.attr('data-video-id')
          
          if stream.videos.where(video_id: @scraped_id).blank?
          
          
   video = stream.videos.find_or_create_by( video_id: @scraped_id, 
                                             pid: playlist.playlist_id, 
                                             length: JSON.parse(open("http://gdata.youtube.com/feeds/api/videos/#{@scraped_id}?v=2&alt=jsonc").read)['data']['duration'],
                                             name:  JSON.parse(open("http://gdata.youtube.com/feeds/api/videos/#{@scraped_id}?v=2&alt=jsonc").read)['data']['title'],
                                             url: "https://www.youtube.com/watch?v=" + "#{@scraped_id}",
                                             y_date_added: JSON.parse(open("http://gdata.youtube.com/feeds/api/videos/#{@scraped_id}?v=2&alt=jsonc").read)['data']['uploaded']
                                            )
          else
              next
          end                     
                                   
          rescue OpenURI::HTTPError
              next
          end

        end
    
  end # end playlist loop
####################################################################################   
=end  
  stream.channels.each do |channel|
    
    doc = Nokogiri::HTML(open(channel.doc))
    
    doc.css("[data-video-ids]").each do |el|
          begin
          @scraped_id = el.attr('data-video-ids')
          
          if stream.videos.where(video_id: @scraped_id).blank?
            
            video = stream.videos.find_or_create_by( video_id: @scraped_id, 
                                                      pid: channel.url, 
                                                      length: JSON.parse(open("http://gdata.youtube.com/feeds/api/videos/#{@scraped_id}?v=2&alt=jsonc").read)['data']['duration'],
                                                      name:  JSON.parse(open("http://gdata.youtube.com/feeds/api/videos/#{@scraped_id}?v=2&alt=jsonc").read)['data']['title'],
                                                      url: "https://www.youtube.com/watch?v=" + "#{@scraped_id}",
                                                      y_date_added: JSON.parse(open("http://gdata.youtube.com/feeds/api/videos/#{@scraped_id}?v=2&alt=jsonc").read)['data']['uploaded']
                                                     ) 
            video.save
           else
              break
           end                                        
                                                  
          rescue OpenURI::HTTPError
              next
          end
          
    end
  
  end # end channel loop
  
#################################################################################### 
  stream.save
  
  # REMOVE OLD CONTENT
  footagelength = stream.videos.pluck(:length).inject(:+) 
  
  #4 hours = 14400
  avgtime = 14400
  
  while footagelength > avgtime
    firstvideo = stream.videos.order('y_date_added asc').first
    firstvideo.destroy
    stream.save
    footagelength = stream.videos.pluck(:length).inject(:+) 
  end
  
#################################################################################### 
  
  # PROGRAM THE STREAM

  @ids, @lengths = stream.videos.pluck(:video_id, :length).shuffle.transpose
  stream.totallength = stream.videos.pluck(:length).inject(:+)     
  stream.idlist = @ids
  stream.lengthlist = @lengths
  
  # DONE
  stream.reprogrammed_at = Time.now
  stream.save
  
end #if allowed
end #if present

end #end each stream
end

end