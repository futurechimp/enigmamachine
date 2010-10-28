require 'rubygems'
require 'sinatra/base'
require 'rack/test'
require 'base64'
require 'machinist/data_mapper'
require 'faker'
require 'sham'
require File.dirname(__FILE__) + '/../lib/enigmamachine'
require File.expand_path(File.dirname(__FILE__) + "/support/blueprints")


ENV['RACK_ENV'] = 'test'

module TestHelper

  def app
    EnigmaMachine.new
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

def http_file_location
  "http://foo.org/bar/blah.wmv"
end

