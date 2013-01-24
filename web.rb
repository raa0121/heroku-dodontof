$LOAD_PATH << File.dirname(__FILE__) + "/DodontoF"
load 'DodontoF/DodontoFServer.rb'
require 'sinatra/base'

class DodontoFApp < Sinatra::Base
  
  get '/DodontoF/DodontoF.swf' do
    send_file File.expand_path("DodontoF",__FILE__),
        :type => 'application/x-shockwave-flash', :dispositon => 'inline' \
      rescue raise(Sinatra::NotFound)
  end
end


