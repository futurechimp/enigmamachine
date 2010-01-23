require 'helper'

class TestEnigmamachine < Test::Unit::TestCase

  context "on GET to / without credentials" do
    setup do
      get '/'
    end

    should "respond with security error" do
      assert !last_response.ok?
      assert_equal 401, status
    end
  end

  context "on GET to / with credentials" do
    setup do
      get '/', {}, basic_auth_creds
    end

    should "respond" do
      assert last_response.ok?
    end

    context "when there is one Video" do
      setup do
        Video.make
        get '/', {}, basic_auth_creds
      end

      should "work" do
        assert last_response.ok?

      end
    end
  end

  context "on GET to /encoders" do
    context "without credentials" do
      setup do
        get '/encoders'
      end

      should "respond with security error" do
        assert !last_response.ok?
        assert_equal 401, status
      end
    end

    context "with credentials" do
      setup do
        get '/encoders', {}, basic_auth_creds
      end

      should "work" do
        assert last_response.ok?
      end

      context "when some encoders exist" do
        setup do
          2.times { Encoder.make }
        end

        should "still work" do
          assert last_response.ok?
        end
      end
    end
  end

  context "on GET to /encoders/new" do
    context "without credentials" do
      setup do
        get '/encoders/new'
      end

      should "respond with security error" do
        assert !last_response.ok?
        assert_equal 401, status
      end
    end

    context "with credentials" do
      setup do
        get '/encoders/new', {}, basic_auth_creds
      end

      should "work" do
        assert last_response.ok?
      end
    end

  end
end

