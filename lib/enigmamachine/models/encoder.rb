require File.dirname(__FILE__) + '/video'
require 'net/http'
require 'uri'

# An encoding profile which can be applied to a video.  It has a name and is
# composed of a bunch of EncodingTasks.
#
# The Encoder class can shell out to FFMPeg and trigger the encoding of a Video.
#
class Encoder
  include DataMapper::Resource

  # Properties
  #
  property :id, Serial
  property :name, String, :required => true, :length => (1..254)

  # Associations
  #
  has n, :encoding_tasks

end

