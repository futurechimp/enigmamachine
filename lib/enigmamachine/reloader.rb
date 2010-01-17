# Reload scripts and reset routes on change
class Sinatra::Reloader < Rack::Reloader
   def safe_load(file, mtime, stderr = $stderr)
     if file == __FILE__
       ::Sinatra::Application.reset!
       stderr.puts "#{self.class}: resetting routes"
     end
     super
   end
end

