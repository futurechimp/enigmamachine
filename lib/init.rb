# Gems
#
require 'rubygems'
require 'sinatra/base'
require 'data_mapper'
require 'ruby-debug'
require 'eventmachine'
require 'rack-flash'
require 'dm-validations'
require 'dm-migrations'
require 'open3'
require 'logger'

# Extensions to Sinatra
#
require File.dirname(__FILE__) +  '/ext/partials'
require File.dirname(__FILE__) +  '/ext/array_ext'

# Enigma code
#
require File.dirname(__FILE__) + '/enigmamachine'
require File.dirname(__FILE__) + '/enigmamachine/models/encoder'
require File.dirname(__FILE__) + '/enigmamachine/models/encoding_task'
require File.dirname(__FILE__) + '/enigmamachine/models/video'
require File.dirname(__FILE__) + '/enigmamachine/encoding_queue'

