require 'open-uri'
require 'json'
require 'openssl'

silence_warnings do
  OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE
end

class FilterJob

def perform
  
  timenow = Time.now.to_i
  
  Stream.all.each do |stream|
    
if stream.videos.first.present? 
        
if timenow >= stream.totallength + stream.reprogrammed_at.to_i    
####################################################################################       
  stream.playlists.each do |playlist|
    
     doc = Nokogiri::HTML(open("https://www.youtube.com/playlist?list=#{playlist.playlist_id}"))

        doc.css("[data-video-id]").each do |el|
          begin
          @scraped_id = el.attr('data-video-id')
          
          if stream.videos.where(video_id: @scraped_id).blank?
          
          length = get_youtube_video_duration(@scraped_id)
          
   video = stream.videos.find_or_create_by( video_id: @scraped_id, 
                                             pid: playlist.playlist_id, 
                                             length: length,
                                             name:  JSON.parse(open("https://www.googleapis.com/youtube/v3/videos?id=#{@scraped_id}&key=AIzaSyBD1bw3Tt2UX-kc_HgDTF2nKxyGfjcfIZ4&fields=items(snippet(title))&part=snippet").read)["items"][0]["snippet"]["title"],
                                             url: "https://www.youtube.com/watch?v=" + "#{@scraped_id}",
                                             y_date_added: Time.now
                                            )
          video.save
          else
              break
          end                     
                                   
          rescue OpenURI::HTTPError
              next
          end

        end
    
  end # end playlist loop
####################################################################################   
  stream.channels.each do |channel|
    
    doc = Nokogiri::HTML(open(channel.doc))
    
    doc.css("[data-video-ids]").each do |el|
          begin
          @scraped_id = el.attr('data-video-ids')
          
          if stream.videos.where(video_id: @scraped_id).blank?

          length = get_youtube_video_duration(@scraped_id)
            
            video = stream.videos.find_or_create_by( video_id: @scraped_id, 
                                                      pid: channel.url, 
                                                      length: length,
                                                      name:  JSON.parse(open("https://www.googleapis.com/youtube/v3/videos?id=#{@scraped_id}&key=AIzaSyBD1bw3Tt2UX-kc_HgDTF2nKxyGfjcfIZ4&fields=items(snippet(title))&part=snippet").read)["items"][0]["snippet"]["title"],
                                                      url: "https://www.youtube.com/watch?v=" + "#{@scraped_id}",
                                                      y_date_added: Time.now
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