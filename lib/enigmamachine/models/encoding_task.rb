# A task which defines how a video will be encoded.
#
class EncodingTask
  include DataMapper::Resource

  # Properties
  #
  property :id, Serial
  property :name, String, :required => true, :length => (1..254)
  property :output_file_suffix, String, :required => true, :length => (1..254)
  property :command, String, :required => true, :length => (1..254)
  property :encoder_id, Integer

  # Associations
  #
  belongs_to :encoder

end

