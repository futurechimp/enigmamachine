class DownloadQueue

  # Adds a periodic timer to the Eventmachine reactor loop and immediately
  # starts looking for videos to download.
  #
  def initialize
    if EnigmaMachine.enable_http_downloads
      EM.add_periodic_timer(5) do
        download_next_video
      end
    end
  end


  # Gets the next waiting_for_download Video from the database and
  # starts downloading it.
  #
  def download_next_video
    if Video.waiting_for_download.count > 0 && Video.downloading.count == 0
      video = Video.waiting_for_download.first
      begin
        puts "downloading video #{video.id}"
        video.download!
      rescue Exception => ex
        # don't do anything just yet, until we set up logging properly.
      end
    end
  end

end

