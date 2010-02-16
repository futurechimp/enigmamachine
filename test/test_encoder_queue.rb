require File.dirname(__FILE__) + '/helper'

class TestEncoderQueue < Test::Unit::TestCase

  context "the encode_next_video method" do
    setup do
      destroy_all_videos
      @video = Video.make
      @task = EncodingTask.make(:with_encoder)
      @video.encoder = @task.encoder
      @video.save
      @queue = EncodingQueue.new
      @queue.encode_next_video
      sleep 1
    end

    should "exist" do
      assert @queue.respond_to? "encode_next_video"
    end

    should "start encoding the video" do
      v = Video.get(@video.id)
      assert_equal "encoding", v.state
    end
  end

  private

  def destroy_all_videos
    Video.all.each { |v| v.destroy! }
  end

end

