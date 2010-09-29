require File.dirname(__FILE__) + '/helper'

class TestVideo <  Test::Unit::TestCase


  context "A Video instance" do

    should "be invalid with a bad file path" do
      resource = ::Video.make
      resource.file = ""
      assert(!resource.valid?, "must not be empty")
      resource.file = nil
      assert(!resource.valid?, "must not be nil")
      resource.file = "/fdfdf/sfdsdfsd/fse.gfr"
      assert(!resource.valid?, "must be exist")
      resource.file = File.dirname(__FILE__)
      assert(!resource.valid?, "must not be a directory")
      resource.file = __FILE__
      assert(!resource.valid?, "must be media file")
    end

    should "be valid without a callback_url" do
      resource = ::Video.make
      resource.callback_url = ""
      assert resource.valid?
      resource.callback_url = nil
      assert resource.valid?
    end

    should "be valid with a callback_url" do
      resource = ::Video.make
      resource.callback_url = "blah"
      assert resource.valid?
    end

    should "be valid with a correct file path" do
      resource = ::Video.make
      assert resource.valid?
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

    context "when try to delete any kind of videos from base" do
      setup do
        clear_videos
        5.times { Video.make }
      end

      should "be delete an unencoded videos" do
        count = Video.unencoded.count
        2.times { Video.unencoded.first.destroy }
        assert_equal count - 2, Video.unencoded.count
      end

      should "be delete a completed videos" do
        3.times { Video.unencoded.first.update(:state => "complete") }
        count = Video.complete.count
        2.times { Video.complete.first.destroy }
        assert_equal count - 2, Video.complete.count
      end

      should "be delete a videos with errors" do
        3.times { Video.unencoded.first.update(:state => "error") }
        count = Video.with_errors.count
        2.times { Video.with_errors.first.destroy  }
        assert_equal count - 2, Video.with_errors.count
      end

      should "not be delete an encoding videos" do
        3.times { Video.unencoded.first.update(:state => "encoding") }
        count = Video.encoding.count
        2.times { Video.encoding.first.destroy }
        assert_equal count, Video.encoding.count
      end

      should "be hard delete an encoding videos" do
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

