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

  context "on GET to /encoder/:id" do
    context "without credentials" do
      setup do
        get "/encoder/#{Encoder.first.id}"
      end

      should "respond with security error" do
        assert !last_response.ok?
        assert_equal 401, status
      end
    end

    context "with credentials" do
      setup do
        get "/encoders/#{Encoder.first.id}", {:id => Encoder.first.id}, basic_auth_creds
      end

      should "work" do
        assert last_response.ok?
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

  context "on GET to /encoders/edit" do
    setup do
      @encoder = Encoder.make
    end

    context "without credentials" do
      setup do
        get "/encoders/#{@encoder.id}/edit"
      end

      should "respond with security error" do
        assert !last_response.ok?
        assert_equal 401, status
      end
    end

    context "with credentials" do
      setup do
        get "/encoders/#{@encoder.id}/edit", {}, basic_auth_creds
      end

      should "work" do
        assert last_response.ok?
      end
    end
  end

  context "on POST to /encoders" do
    context "without credentials" do
      setup do
        post "/encoders", Encoder.plan
      end

      should "respond with security error" do
        assert !last_response.ok?
        assert_equal 401, status
      end
    end

    context "with credentials" do

      context "and valid Encoder params" do
        setup do
          @num_encoders = Encoder.count
          post "/encoders", {:encoder => Encoder.plan}, basic_auth_creds
          follow_redirect!
        end

        should "create an Encoder object" do
          assert_equal "http://example.org/encoders/#{Encoder.last.id}", last_request.url
          assert_equal @num_encoders + 1, Encoder.count
        end
      end

      context "and invalid Encoder params" do
        setup do
          @num_encoders = Encoder.count
          post "/encoders", {:encoder => Encoder.plan.merge(:name => "")}, basic_auth_creds
        end

        should "redisplay the form" do
          assert_equal "http://example.org/encoders", last_request.url
        end

        should "not create an Encoder object" do
          assert_equal @num_encoders, Encoder.count
        end
      end
    end
  end

  context "on PUT to /encoders/:id" do
    context "without credentials" do
      setup do
        put "/encoders/#{Encoder.first.id}", {:encoder => Encoder.plan}
      end

      should "respond with security error" do
        assert !last_response.ok?
        assert_equal 401, status
      end
    end

    context "with credentials" do
      context "and valid encoder params" do
        setup do
          put "/encoders/#{Encoder.first.id}", {:id => Encoder.first.id, :encoder => Encoder.plan}, basic_auth_creds
          @num_encoders = Encoder.count
          follow_redirect!
        end

        should "work" do
          assert_equal "http://example.org/encoders", last_request.url
        end

        should "not create a new Encoder object" do
          assert_equal @num_encoders, Encoder.count
        end
      end

    context "and invalid encoder params" do
        setup do
          put "/encoders/#{Encoder.first.id}", {
            :id => Encoder.first.id,
            :encoder => Encoder.plan.merge(:name => "")}, basic_auth_creds
          @num_encoders = Encoder.count
        end

        should "redisplay the edit form" do
          assert_equal "http://example.org/encoders/#{Encoder.first.id}", last_request.url
        end

        should "not create a new Encoder object" do
          assert_equal @num_encoders, Encoder.count
        end
      end

    end
  end

  context "on DELETE to /encoders" do
    context "without credentials" do
      setup do
        @encoder = Encoder.make
        delete "/encoders/#{@encoder.id}", {:id => @encoder.id}
      end

      should "respond with security error" do
        assert !last_response.ok?
        assert_equal 401, status
      end
    end

    context "with credentials" do
      setup do
        @encoder = Encoder.make
        @num_encoders = Encoder.count
        delete "/encoders/#{@encoder.id}", {:id => @encoder.id}, basic_auth_creds
        follow_redirect!
      end

      should "destroy the encoder" do
        assert_equal @num_encoders - 1, Encoder.count
      end

      should "redirect to the encoder list page" do
        assert_equal "http://example.org/encoders", last_request.url
      end
    end
  end

  context "on GET to /encoding_tasks/new/:encoder_id" do
    context "without credentials" do
      setup do
        get "/encoding_tasks/new/#{Encoder.first.id}"
      end

      should "respond with security error" do
        assert !last_response.ok?
        assert_equal 401, status
      end
    end

    context "with credentials" do
      setup do
        get "/encoding_tasks/new/#{Encoder.first.id}", {}, basic_auth_creds
      end

      should "work" do
        assert last_response.ok?
      end
    end
  end

  context "on POST to /encoding_tasks/:encoder_id" do
    context "without credentials" do
      setup do
        post "/encoding_tasks/#{Encoder.first.id}"
      end

      should "respond with security error" do
        assert !last_response.ok?
        assert_equal 401, status
      end
    end

    context "with credentials" do
      context "and valid EncodingTask params" do
        setup do
          @num_tasks = EncodingTask.count
          post "/encoding_tasks/#{Encoder.first.id}", {:encoding_task => EncodingTask.plan}, basic_auth_creds
          follow_redirect!
        end

        should "create a new encoding task" do
          assert_equal @num_tasks + 1, EncodingTask.count
        end

        should "redirect to parent encoder show page" do
          assert_equal "http://example.org/encoders/#{Encoder.first.id}", last_request.url
        end
      end

      context "and invalid EncodingTask params" do
        setup do
          @num_tasks = EncodingTask.count
          post "/encoding_tasks/#{Encoder.first.id}", {
            :encoding_task => EncodingTask.plan.merge(:name => "")}, basic_auth_creds
        end

        should "not create a new encoding task" do
          assert_equal @num_tasks, EncodingTask.count
        end

        should "redisplay the EncodingTask form" do
          assert last_response.ok?
        end
      end
    end
  end

  context "on PUT to /encoding_tasks/:id" do
    context "without credentials" do
      setup do
        put "/encoding_tasks/#{Encoder.first.id}"
      end

      should "respond with security error" do
        assert !last_response.ok?
        assert_equal 401, status
      end
    end

    context "with credentials" do
      context "and valid EncodingTask params" do
        setup do
          @encoding_task = EncodingTask.make(:with_encoder)
          @num_tasks = EncodingTask.count
          put "/encoding_tasks/#{@encoding_task.id}", {:id => @encoding_task.id, :encoding_task => EncodingTask.plan}, basic_auth_creds
          follow_redirect!
        end

        should "not create a new encoding task" do
          assert_equal @num_tasks, EncodingTask.count
        end

        should "redirect to parent encoder show page" do
          assert_equal "http://example.org/encoders/#{@encoding_task.encoder.id}", last_request.url
        end
      end

      context "and invalid EncodingTask params" do
        setup do
          @encoding_task = EncodingTask.make(:with_encoder)
          @num_tasks = EncodingTask.count
          put "/encoding_tasks/#{@encoding_task.id}", {
            :encoding_task => EncodingTask.plan.merge(:name => "")}, basic_auth_creds
        end

        should "not create a new encoding task" do
          assert_equal @num_tasks, EncodingTask.count
        end

        should "redisplay the EncodingTask form" do
          assert last_response.ok?
        end
      end
    end
  end

  context "on DELETE to /encoding_tasks/:id" do
    context "without credentials" do
      setup do
        @task = EncodingTask.make
        delete "/encoding_tasks/#{@task.id}"
      end

      should "respond with security error" do
        assert !last_response.ok?
        assert_equal 401, status
      end
    end

    context "with credentials" do
      setup do
        @task = EncodingTask.make
        @num_tasks = EncodingTask.count
        delete "/encoding_tasks/#{@task.id}", {:id => @task.id}, basic_auth_creds
      end

      should "destroy the task" do
        assert_equal @num_tasks - 1, EncodingTask.count
      end

    end
  end


  context "on GET to /videos" do
    context "without credentials" do
      setup do
        get "/videos"
      end

      should "respond with security error" do
        assert !last_response.ok?
        assert_equal 401, status
      end
    end

    context "with credentials" do
      setup do
        get "/videos", {}, basic_auth_creds
      end

      should "work" do
        assert last_response.ok?
      end
    end
  end

  context "on GET to /videos/new" do
    context "without credentials" do
      setup do
        get "/videos/new"
      end

      should "respond with security error" do
        assert !last_response.ok?
        assert_equal 401, status
      end
    end
  end

  context "with credentials" do
    setup do
      get "/videos/new", {}, basic_auth_creds
    end

    should "work" do
      assert last_response.ok?
    end
  end

  context "on POST to /videos" do
    context "without credentials" do
      setup do
        post "/videos", {:video => Video.plan}
      end

      should "respond with security error" do
        assert !last_response.ok?
        assert_equal 401, status
      end
    end

    context "with credentials" do
      context "and valid video params" do
        setup do
          @num_videos = Video.count
          post "/videos", {
            :video => Video.plan,
            :encoder_id => Encoder.make.id}, basic_auth_creds
          follow_redirect!
        end

        should "create a video" do
          assert_equal @num_videos + 1, Video.count
        end

        should "redirect to /videos" do
          assert_equal "http://example.org/videos", last_request.url
        end
      end

      context "and invalid video params" do
        setup do
          @num_videos = Video.count
          post "/videos", {
            :video => Video.plan.merge(:file => ""),
            :encoder_id => Encoder.make.id}, basic_auth_creds
        end

        should "not create a new video" do
          assert_equal @num_videos, Video.count
        end

        should "redisplay the video form" do
          assert last_response.ok?
        end
      end
    end
  end

end

