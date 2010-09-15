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

  belongs_to :encoder

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

end

