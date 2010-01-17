# A task which defines how a video will be encoded.
#
class EncodingTask
  include DataMapper::Resource

  # Properties
  #
  property :id, Serial, :key => true
  property :name, String, :required => true, :length => (1..254)
  property :output_file_suffix, String, :required => true, :length => (1..254)
  property :command, String, :required => true, :length => (1..254)

  # Associations
  #
  belongs_to :encoder

end

# An encoding profile which can be applied to a video.  It has a name and is
# composed of a bunch of EncodingTasks.
#
class Encoder
  include DataMapper::Resource

  # Properties
  #
  property :id, Serial, :key => true
  property :name, String, :required => true, :length => (1..254)

  # Associations
  #
  has n, :encoding_tasks, :order => [:id.desc]

  # This is a candidate for being moved into the class Encoders::Video (which
  # could happily be renamed as something like Encoders::Ffmpeg).
  #
  def encode(video)
    ffmpeg(encoding_tasks.first, video)
  end

  private

  # If the encode method is pulled into another class, this one should go with
  # it, obviously.
  #
  def ffmpeg(task, video)
    current_task_index = encoding_tasks.index(task)
    command_string = "ffmpeg -i #{video.file} #{task.command} #{video.file + task.output_file_suffix}"
    encoding_operation = proc {
      video.state = "encoding"
      video.save
      Log.info("Executing: #{task.name}")
      `nice -n 19 #{command_string}`
    }
    completion_callback = proc {|result|
      if task == encoding_tasks.last
        video.state = "complete"
        video.save
      else
        next_task_index = current_task_index + 1
        next_task = encoding_tasks[next_task_index]
        ffmpeg(next_task, video)
      end
    }
    EventMachine.defer(encoding_operation, completion_callback)
  end

end


# A video which we want to encode.
#
class Video
  include DataMapper::Resource

  # Properties
  #
  property :id, Serial, :key => true
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

