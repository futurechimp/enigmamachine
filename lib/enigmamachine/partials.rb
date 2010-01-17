# An implementation of partials for Sinatra.
#
# Can be used like: <%= partial(:foo) %>
#
# Unlike Rails partials, the .erb files for these partials do not start with a
# leading underscore, i.e. the file name should be foo.rb, not _foo.rb.
#
# Liberated from:
# http://github.com/cschneid/irclogger/blob/master/lib/partials.rb
#
module Sinatra
  module Partials
    def partial(template, *args)
      options = args.extract_options!
      options.merge!(:layout => false)
      if collection = options.delete(:collection) then
        collection.inject([]) do |buffer, member|
          buffer << erb(template, options.merge(:layout => 
          false, :locals => {template.to_s.gsub!("/", "_").to_sym => member}))
          # check with template.to_s.split("/").last.to_sym => member
      end.join("\n")
      else
        erb(template, options)
      end
    end
  end
end

