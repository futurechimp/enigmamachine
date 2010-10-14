require File.dirname(__FILE__) + '/helper'

class TestVideo <  Test::Unit::TestCase


  context "A Video instance" do

    should "be invalid with a bad file path" do
      video = Video.make
      video.file = ""
      assert(!video.valid?, "must not be empty")
      video.file = nil
      assert(!video.valid?, "must not be nil")
      video.file = "/fdfdf/sfdsdfsd/fse.gfr"
      assert(!video.valid?, "must be exist")
      video.file = File.dirname(__FILE__)
      assert(!video.valid?, "must not be a directory")
      video.file = __FILE__
      assert(!video.valid?, "must be media file")
    end

    should "be valid without a callback_url" do
      video = Video.make
      video.callback_url = ""
      assert video.valid?
      video.callback_url = nil
      assert video.valid?
    end

    should "be valid with a callback_url" do
      video = Video.make
      video.callback_url = "blah"
      assert video.valid?
    end

    should "be valid with a correct file path" do
      video = ::Video.make
      assert video.valid?
    end

    should "belong to an Encoder" do
      v = Video.make_unsaved
      assert v.respond_to? "encoder"
    end

    should "allow itself to be associated with an Encoder" do
      v = Video.make_unsaved
      e = Encoder.make_unsaved
      assert_nothing_raised do
        v.encoder = e
      end
    end

    context "on a local filesystem" do
      setup do
        @video = Video.make
      end

      should "have an initial state of 'unencoded'" do
        assert_equal("unencoded", @video.state)
      end

      should "transition to state 'encoding' on 'encode!' command" do
        @video.encode!
        assert_equal("encoding", @video.state)
      end

      should "transition to state 'unencoded' on 'reset!' command" do
        @video.encode!
        @video.reset!
        assert_equal("unencoded", @video.state)
      end

    end

#    context "available via http" do
#    end

  end

  context "The Video class" do

    should "be able to grab all unencoded videos" do
      assert Video.respond_to? "unencoded"
    end

    context "when one Video exists" do
      setup do
        clear_videos
        Video.make(:state => "unencoded")
      end

      should "have one unencoded video" do
        assert_equal 1, Video.unencoded.count
      end
    end

    context "when two Videos exist" do
      setup do
        clear_videos
        2.times { Video.make }
      end

      should "have two unencoded videos" do
        assert_equal 2, Video.unencoded.count
      end
    end

    context "when trying to delete any kind of videos from base" do
      setup do
        clear_videos
        5.times { Video.make }
      end

      should "delete an unencoded video" do
        count = Video.unencoded.count
        2.times { Video.unencoded.first.destroy }
        assert_equal count - 2, Video.unencoded.count
      end

      should "delete a completed video" do
        3.times { Video.unencoded.first.update(:state => "complete") }
        count = Video.complete.count
        2.times { Video.complete.first.destroy }
        assert_equal count - 2, Video.complete.count
      end

      should "delete videos with errors" do
        3.times { Video.unencoded.first.update(:state => "error") }
        count = Video.with_errors.count
        2.times { Video.with_errors.first.destroy  }
        assert_equal count - 2, Video.with_errors.count
      end

      should "not delete an encoding video" do
        3.times { Video.unencoded.first.update(:state => "encoding") }
        count = Video.encoding.count
        2.times { Video.encoding.first.destroy }
        assert_equal count, Video.encoding.count
      end

      should "allow force destroy of an encoding video" do
        3.times { Video.unencoded.first.update(:state => "encoding") }
        count = Video.encoding.count
        2.times { Video.encoding.first.destroy! }
        assert_equal count - 2, Video.encoding.count
      end

    end

    should "be able to grab all completed videos" do
      assert Video.respond_to? "complete"
    end

    should "be able to grab all videos with errors" do
      assert Video.respond_to? "with_errors"
    end

    should "be able to grab all videos that are encoding" do
      assert Video.respond_to? "encoding"
    end

  end

  def clear_videos
    Video.all.each  {|v| v.destroy! }
  end

end

