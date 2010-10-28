require File.dirname(__FILE__) + '/encoder'
require 'net/http'
require 'uri'

# A video which we want to encode.
#
class Video
  include DataMapper::Resource

  # Properties
  #
  property :id, Serial
  property :file, String,  :required => true, :length => (1..510)
  property :created_at, DateTime
  property :updated_at, DateTime
  property :encoder_id, Integer, :required => true
  property :callback_url, String

  # State machine transitions
  #
  is :state_machine, :column => :state do

    # States for HTTP-hosted videos
    state :waiting_for_download
    state :downloading, :enter => :do_download
    state :download_error

    # States for videos on the local filesystem
    state :unencoded
    state :encoding, :enter => :do_encode
    state :error
    state :complete, :enter => :notify_complete

    event :download do
      transition :from => :waiting_for_download, :to => :downloading
    end

    event :download_complete do
      transition :from => :downloading, :to => :unencoded
    end

    event :download_error do
      transition :from => :downloading, :to => :download_error
    end

    event :encode do
      transition :from => :unencoded,  :to => :encoding
    end

    event :complete do
      transition :from => :encoding, :to => :complete
    end

    event :reset do
      transition :from => :encoding, :to => :unencoded
    end

  end

  # Validations
  #
  validates_uniqueness_of :file, :scope => :encoder_id,
    :message => "Same file with same encoder already exists"
  validates_with_method :file, :method => :check_file

  # Associations
  #
  belongs_to :encoder

  # Filters
  #
  before :destroy, :check_destroy
  before :create, :set_initial_state

  default_scope(:default).update(:order => [:created_at.asc])


  # Named scope for all videos which are waiting to start encoding.
  #
  def self.unencoded
    all(:state => 'unencoded')
  end

  # Named scope for all videos which are currently encoding.  Theoretically
  # there should only ever be one.
  #
  def self.encoding
    all(:state => 'encoding')
  end

  # Named scope giving back all videos with encoding errors.
  #
  def self.with_errors
    all(:state => 'error')
  end

  # Named scope giving back all videos which have completed encoding.
  #
  def self.complete
    all(:state => 'complete', :order => [:updated_at.desc])
  end

  # Named scope returning all videos which are not yet downloaded.
  #
  def self.waiting_for_download
    all(:state => 'waiting_for_download')
  end

  # Named scope returning all videos which currently downloading.
  #
  def self.downloading
    all(:state => 'downloading')
  end

  # Resets all videos currently marked as "encoding" to state "unencoded"
  # which is the initial state.
  #
  # If any videos are marked as "encoding" when the application starts,
  # presumably due to an encoding interruption in the last session, they
  # should be reset.
  #
  def self.reset_encoding_videos
    Video.encoding.each do |video|
      video.reset!
    end
  end

  def to_s
    "Hi, I'm video #{self.id}"
  end

  private

  # Validation checks for files - we want to ensure that the video file exists,
  # and that it can be encoded by ffmpeg.
  #
  def check_file
    if local?
      return [false, "Give a file name, not nil"] if self.file.nil?
      return [false, "Give a file name, not a blank string"] if self.file.to_s.empty?
      return [false, "#{self.file} does not exist"] unless File.exist? self.file
      return [false, "#{self.file} is a directory"] if File.directory? self.file
      movie = FFMPEG::Movie.new(self.file)
      return [false, "#{self.file} is not a media file"] unless movie.valid?
    end
    return true
  end

  # Returns true unless the video's file starts with 'http://'
  #
  def set_initial_state
    if local?
      self.state = "unencoded"
    else
      self.state = "waiting_for_download"
    end
  end

  # Checks whether a video object can be destroyed - videos cannot be destroyed
  # if they are currently encoding.
  #
  def check_destroy
    return true if (self.state != 'encoding')
    return true if stop_encode
    throw :halt
  end

  # Would stop the encoder process if it was implemented.  Currently does nothing
  # and returns false.
  #
  def stop_encode
    return false
    #TODO Kill the encoder process
  end

  # Tells this video's encoder to start encoding tasks.
  #
  def do_encode
    ffmpeg(encoder.encoding_tasks.first)
  end

  # Shells out to ffmpeg and hits the given video with the parameters in the
  # given task.  Will call itself recursively until all tasks in the encoder's
  # encoding_tasks are completed.
  #
  def ffmpeg(task)
    current_task_index = encoder.encoding_tasks.index(task)
    movie = FFMPEG::Movie.new(file)
    encoding_operation = proc {
      movie.transcode(file + task.output_file_suffix, task.command)
    }
    completion_callback = proc {|result|
      if task == encoder.encoding_tasks.last
        self.complete!
      else
        next_task_index = current_task_index + 1
        next_task = encoder.encoding_tasks[next_task_index]
        ffmpeg(next_task)
      end
    }
    EventMachine.defer(encoding_operation, completion_callback)
  end

  # Notifies a calling application that processing has completed by sending
  # a GET request to the video's callback_url.
  #
  def notify_complete
    begin
      Net::HTTP.get(URI.parse(video.callback_url)) unless callback_url.nil?
    rescue
    end
  end

  # Downloads a video from a remote location via HTTP
  #
  # HACK: it's not possible call a DM state machine event from a method
  # which is itself tied to a DM state machine transition (like this one is),
  # because dm-is_state_machine doesn't update the state before triggered methods
  # are called. It's a chicken-and-egg situation. So I'm hitting it with the
  # big hammer and setting state manually.
  #
  # This is a disgusting abuse of the state machine, but it works.
  #
  # NOTE: By the time this method is complete, tests will assume our state is
  # "unencoded" (as a result of the download_complete! event) rather than
  # "downloading", as it should be.
  #
  def do_download
    self.state = "downloading"
    self.save!
    http = EventMachine::HttpRequest.new(file).get :timeout => 10

    http.stream do |data|
      filename = File.basename(URI.parse(file).path)
      outfile = File.join(Dir.pwd, "downloads", self.id.to_s, filename)
      File.open(outfile, 'a') {|f| f.write(data) }
    end

    http.callback do
      download_complete!
    end

    http.errback do
      download_error!
    end
  end

  # Returns false if the video is available via http
  #
  def local?
    return false if self.file =~ /^http:\/\//
    return true
  end

end

