before do
  response.headers['Cache-Control'] = 'public, max-age=604800' if production?
end

get '/stylesheets/*.css' do |file_name|
  sass(file_name.to_sym)
end

get '/' do
  markdown(:overview, layout: :layout, layout_engine: :haml)
end

get '/:page' do
  markdown(params[:page].to_sym, layout: :layout, layout_engine: :haml)
end
