class EncodingQueue

  cattr_accessor :currently_encoding

  # Adds a periodic timer to the Eventmachine reactor loop and immediately
  # starts looking for unencoded videos.
  #
  def initialize
    EM.add_periodic_timer(5) {
      encode_next_video
    }
    encode_next_video
  end


  # Gets the next unencoded Video from the database and starts encoding it.
  #
  def encode_next_video
    if Video.unencoded.count > 0 && ::Video.encoding.count == 0
      video = Video.unencoded.first
      begin
        video.encoder.encode(video)
      rescue Exception => ex
        File.open('/home/dave/test.txt', 'w') do |f|
          f.puts ex
        end
      end
    end
  end

end

