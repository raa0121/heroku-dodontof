$LOAD_PATH << File.dirname(__FILE__) + "/DodontoF"
load 'DodontoFServer'
require 'sinatra/base'

class DodontoFApp < Sinatra::Base
  
  post '/DodontoF/DodontoF.swf' do
    send_file File.expand_path("DodontoF",__FILE__),
        :type => 'application/x-shockwave-flash', :dispositon => 'inline' \
      rescue raise(Sinatra::NotFound)
  end
end
