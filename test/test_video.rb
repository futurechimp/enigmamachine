require File.dirname(__FILE__) + '/helper'

class TestVideo <  Test::Unit::TestCase


  context "A Video instance" do

    should "be invalid without a file path" do
      resource = ::Video.make_unsaved
      resource.file = ""
      assert !resource.valid?
      resource.file = nil
      assert !resource.valid?
    end

    should "be invalid without a callback_url" do
      resource = ::Video.make_unsaved
      resource.callback_url = ""
      assert !resource.valid?
      resource.callback_url = nil
      assert !resource.valid?
    end

    should "be valid with a file path" do
      resource = ::Video.make
      resource.file = "foo.mpg"
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
    Video.all.each  {|v| v.destroy }
  end

end

