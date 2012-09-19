require 'sinatra'
require 'haml'

require "sinatra/reloader" if development?

before do
  response.headers['Cache-Control'] = 'public, max-age=604800' if production?
end

get '/stylesheets/*.css' do |f|
  sass ('/stylesheets/' + f).to_sym
end

get '/pages/:page' do
  @page = request.url.split("/").last
  @content = markdown(:"pages/#{params[:page]}")
  haml :index
end

get '/' do
  haml :index
end
