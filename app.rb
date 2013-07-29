before do
  response.headers['Cache-Control'] = 'public, max-age=604800' if production?
end

helpers do
  def active_class_for(uri_path)
    request.path_info == uri_path ? 'active' : nil
  end

  def root_path
    '/'
  end

  def usage_path
    '/usage'
  end

  def advanced_usage_path
    '/advanced'
  end

  def contributing_path
    '/contributing'
  end

end

get '/stylesheets/*.css' do |file_name|
  sass(file_name.to_sym)
end

get '/' do
  markdown(:overview, layout: :layout, layout_engine: :haml)
end

get '/ping' do
  [200,{'Content-Type' => 'text/plain'},['PONG']]
end

get '/:page' do
  unless params[:page] == 'favicon.ico'
    markdown(params[:page].to_sym, layout: :layout, layout_engine: :haml)
  end
end
