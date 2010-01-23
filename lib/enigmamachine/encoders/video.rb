module Encoders
  class Video

    # Adds a periodic timer to the Eventmachine reactor loop and immediately
    # starts looking for unencoded videos.
    #
    def start
      EM.add_periodic_timer(5) {
        encode_next_video
      }
      encode_next_video
    end


    # Gets the next unencoded Video from the database and starts encoding it.
    #
    def encode_next_video
      if ::Video.unencoded.count > 0 && ::Video.encoding.count == 0
        video = ::Video.unencoded.first
        Log.info("Starting to encode video: #{video.id}")
        begin
          video.encoder.encode(video)
        rescue Exception => ex
          Log.error("Video #{video.id} failed to encode due to error: #{ex}")
        end
      end
    end

  end
end

