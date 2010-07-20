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

  # Kicks off an FFMpeg encode on a given video.
  #
  def encode(video)
    ffmpeg(encoding_tasks.first, video)
  end

  private

  # Shells out to ffmpeg and hits the given video with the parameters in the
  # given task.  Will call itself recursively until all tasks in this encoder's
  # encoding_tasks are completed.
  #
  def ffmpeg(task, video)
    current_task_index = encoding_tasks.index(task)
    command_string = "ffmpeg -y -i #{video.file} #{task.command} #{video.file + task.output_file_suffix}"
    encoding_operation = proc {
      video.state = "encoding"
      video.save
      Open3.popen3 "nice -n 19 #{command_string}" do |stdin, stdout, stderr|
        while stderr.gets()
          puts stderr.gets
        end
      end
    }
    completion_callback = proc {|result|
      if task == encoding_tasks.last
        do_callback_for(video)
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

  def do_callback_for(video)
    begin
      Net::HTTP.get(URI.parse(video.callback_url))
    rescue
    end
  end

end

