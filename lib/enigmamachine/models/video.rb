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

end

