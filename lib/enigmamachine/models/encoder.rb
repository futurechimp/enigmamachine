require File.dirname(__FILE__) + '/video'

# An encoding profile which can be applied to a video.  It has a name and is
# composed of a bunch of EncodingTasks.
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
    command_string = "ffmpeg -i #{video.file} #{task.command} #{video.file + task.output_file_suffix} -y"
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

