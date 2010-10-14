require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "enigmamachine"
    gem.summary = %Q{A RESTful video encoder.}
    gem.description = %Q{A RESTful video encoder which you can use as either a front-end to ffmpeg or headless on a server.}
    gem.email = "dave@caprica"
    gem.homepage = "http://github.com/futurechimp/enigmamachine"
    gem.authors = ["Dave Hrycyszyn", "Dmitry Brazhkin"]
    gem.add_development_dependency "thoughtbot-shoulda", ">= 0"
    gem.add_dependency "data_mapper", ">=1.0.2"
    gem.add_dependency "dm-sqlite-adapter", ">=1.0.2"
    gem.add_dependency "dm-is-state_machine", ">=1.0.2"
    gem.add_dependency "eventmachine", ">=0.12.10"
    gem.add_dependency "rack-flash"
    gem.add_dependency "ruby-debug"
    gem.add_dependency "sinatra", ">=1.0.0"
    gem.add_dependency "streamio-ffmpeg", ">=0.7.3"
    gem.add_dependency "thin"

    # gem is a Gem::Specification... see http://www.rubygems.org/read/chapter/20 for additional settings
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/test_*.rb'
  test.verbose = true
end

begin
  require 'rcov/rcovtask'
  Rcov::RcovTask.new do |test|
    test.libs << 'test'
    test.pattern = 'test/**/test_*.rb'
    test.verbose = true
  end
rescue LoadError
  task :rcov do
    abort "RCov is not available. In order to run rcov, you must: sudo gem install spicycode-rcov"
  end
end

task :test => :check_dependencies

task :default => :test

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "enigmamachine #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

