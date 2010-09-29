require File.dirname(__FILE__) + '/encoder'

# A video which we want to encode.
#
class Video
  include DataMapper::Resource

  # Properties
  #
  property :id, Serial
  property :file, String,  :required => true, :length => (1..510)
  property :state, String, :required => true,
    :length => (1..10), :default => 'unencoded'
  property :created_at, DateTime
  property :updated_at, DateTime
  property :encoder_id, Integer, :required => true
  property :callback_url, String

  validates_with_method :file, :method => :check_file
  validates_uniqueness_of :file, :scope => :encoder_id,
    :message => "Same file with same encoder already exist"
  belongs_to :encoder

  before :destroy, :check_destroy

  # Notifies a calling application that processing has completed by sending
  # a GET request to the video's callback_url.
  #
  def notify_complete
    begin
      Net::HTTP.get(URI.parse(video.callback_url)) unless callback_url.nil?
    rescue
    end
  end


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
      video.state = "unencoded"
      video.save!
    end
  end

  private

  def check_file
    return [false, "Give a file name, not nil"] if self.file.nil?
    return [false, "Give a file name, not clear string"] if self.file.to_s.empty?
    return [false, "#{self.file} is not exist"] unless File.exist? self.file
    return [false, "#{self.file} is a directory"] if File.directory? self.file
    movie = FFMPEG::Movie.new(self.file)
    return [false, "#{self.file} is not a media file"] unless movie.valid?
    return true
  end

  def check_destroy
    return true if (self.state != 'encoding')
    encoder = Encoder.get(self.encoder_id)
    return true if stop_encode
    throw :halt
  end

  def stop_encode
    return false
    #TODO Kill the encoder process
  end

end

