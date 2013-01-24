require 'sinatra'

post '/DodontoF/DodontoF.swf'
  send_file File.expand_path("DodontoF",__FILE__),
      :type => 'application/x-shockwave-flash', :dispositon => 'inline' \
      rescue raise(Sinatra::NotFound)
end
