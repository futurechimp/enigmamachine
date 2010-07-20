require File.dirname(__FILE__) + '/encoder'

# A video which we want to encode.
#
class Video
  include DataMapper::Resource

  # Properties
  #
  property :id, Serial
  property :file, String,  :required => true, :length => (1..254)
  property :state, String, :required => true,
    :length => (1..10), :default => 'unencoded'
  property :created_at, DateTime
  property :updated_at, DateTime
  property :encoder_id, Integer, :required => true
  property :callback_url, String, :required => true, :length => (1..254)

  belongs_to :encoder

  def self.unencoded
    all(:state => 'unencoded')
  end

  def self.encoding
    all(:state => 'encoding')
  end

  def self.with_errors
    all(:state => 'error')
  end

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

