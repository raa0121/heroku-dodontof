$LOAD_PATH << File.dirname(__FILE__) + "/DodontoF"
load 'DodontoF/DodontoFServer.rb'
require 'sinatra/base'

class DodontoFApp < Sinatra::Base
  get '/DodontoF/DodontoF.swf' do
    content_type :swf
    send_file "DodontoF/DodontoF.swf"
  end
  post '/DodontoF/DodontoFServer.rb' do
    `cd DodontoF;ruby DodontoFServer.rb #{params[:obj]}`
  end
  get '/DodontoF/DodontoFServer.rb' do
    `cd DodontoF;ruby DodontoFServer.rb #{params[:obj]}`
  end
end

