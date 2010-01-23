require File.dirname(__FILE__) + '/helper'

class TestEncoderQueue < Test::Unit::TestCase

  context "the encode_next_video method" do
    setup do
      @queue = Encoders::Video.new
    end

    should "exist" do
      assert @queue.respond_to? "encode_next_video"
    end

  end

end

