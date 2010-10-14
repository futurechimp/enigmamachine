class EncodingQueue

  cattr_accessor :currently_encoding

  # Adds a periodic timer to the Eventmachine reactor loop and immediately
  # starts looking for unencoded videos.
  #
  def initialize
    @threads = YAML.load_file(Dir.getwd + '/config.yml')['threads'] if @threads.nil?
    EM.add_periodic_timer(5) {
      encode_next_video
    }
  end


  # Gets the next unencoded Video from the database and starts encoding its file.
  #
  def encode_next_video
    if Video.unencoded.count > 0 && Video.encoding.count < @threads
      video = Video.unencoded.first
      begin
        video.encode!
      rescue Exception => ex
        # don't do anything just yet, until we set up logging properly.
      end
    end
  end

end

