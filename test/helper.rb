require 'rubygems'
require 'sinatra'
require 'rack/test'
require 'base64'
require 'machinist/data_mapper'
require 'faker'
require 'sham'
set :environment, :test
set :run, false
set :raise_errors, true
set :logging, false
require File.dirname(__FILE__) + '/../lib/init'
require File.dirname(__FILE__) + '/../lib/enigmamachine'
require File.expand_path(File.dirname(__FILE__) + "/support/blueprints")



module TestHelper

  def app
    # change to your app class if using the 'classy' style
    Sinatra::Application.new
  end

  def body
    last_response.body
  end

  def status
    last_response.status
  end

  include Rack::Test::Methods

end

require 'test/unit'
require 'shoulda'

Test::Unit::TestCase.send(:include, TestHelper)

def basic_auth_creds(username = 'admin', password = 'admin')
  {'HTTP_AUTHORIZATION'=> encode_credentials(username, password)}
end

def encode_credentials(username, password)
  "Basic " + Base64.encode64("#{username}:#{password}")
end

