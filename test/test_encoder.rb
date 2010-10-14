require File.dirname(__FILE__) + '/helper'

class TestEncoder <  Test::Unit::TestCase

  context "An Encoder instance" do

    setup do
      @encoder = Encoder.make
    end

    should "be invalid without a name" do
      @encoder.name = ""
      assert !@encoder.valid?
    end

    should "have an encoding_tasks association" do
      assert @encoder.respond_to? "encoding_tasks"
    end

    should "allow encoding_tasks to be added" do
      encoder = Encoder.make_unsaved
      task = EncodingTask.make_unsaved
      assert_nothing_raised do
        encoder.encoding_tasks << task
      end
    end

    context "hitting the ffmpeg method" do
      context "for an encoder with 1 task" do
        setup do
          @video = Video.make
          task = EncodingTask.make
          @video.encoder.encoding_tasks << task
          @video.encoder.save
          @video.encode!
          @id = @video.id
          sleep 1
        end

        should "create the file specified in the encoder's first encoding task" do
          suffix = @video.encoder.encoding_tasks.first.output_file_suffix
          file = @video.file + suffix
          assert File.exist? file
        end

        should_eventually "mark the video as complete" do
          sleep 5
          video = Video.get(@id)
          assert_equal "complete", video.state
        end

      end

      context "for an encoder with 2 tasks" do
        setup do
          video = Video.make
          task = EncodingTask.make
          2.times { video.encoder.encoding_tasks << EncodingTask.make }
          video.encoder.save
          video.encode!
          @id = video.id
        end

        should_eventually "mark the video as complete" do
          sleep 1
          video = Video.get(@id)
          assert_equal "complete", video.state
        end
      end

    end
  end
end

