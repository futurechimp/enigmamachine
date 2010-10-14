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
  is :state_machine, :initial => :unencoded, :column => :state do
    state :unencoded
    state :encoding, :enter => :do_encode
    state :error
    state :complete, :enter => :notify_complete

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
  validates_with_method :file, :method => :check_file
  validates_uniqueness_of :file, :scope => :encoder_id,
    :message => "Same file with same encoder already exists"

  # Associations
  #
  belongs_to :encoder

  # Filters
  #
  before :destroy, :check_destroy

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

  private

  # Validation checks for files - we want to ensure that the video file exists,
  # and that it can be encoded by ffmpeg.
  #
  def check_file
    return [false, "Give a file name, not nil"] if self.file.nil?
    return [false, "Give a file name, not a blank string"] if self.file.to_s.empty?
    return [false, "#{self.file} does not exist"] unless File.exist? self.file
    return [false, "#{self.file} is a directory"] if File.directory? self.file
    movie = FFMPEG::Movie.new(self.file)
    return [false, "#{self.file} is not a media file"] unless movie.valid?
    return true
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

end

