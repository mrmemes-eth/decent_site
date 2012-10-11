before do
  response.headers['Cache-Control'] = 'public, max-age=604800' if production?
end

get '/stylesheets/*.css' do |file_name|
  STDOUT.puts file_name.to_sym
  sass(file_name.to_sym)
end

get '/' do
  haml(:index)
end

get '/:page' do
  haml(params[:page])
end
