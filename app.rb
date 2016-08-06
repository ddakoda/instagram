require 'dotenv'
require 'bundler'
Bundler.require()

Dotenv.load

enable :sessions

CALLBACK_URL = ENV['BASE_URI']

Instagram.configure do |config|
  config.client_id = ENV['CLIENT_ID']
  config.client_secret = ENV['CLIENT_SECRET']
end

def new_client
  @client = Instagram.client(:access_token => session[:access_token])
end

get '/' do
  erb :index
end

# Login via instagram oauth
get '/oauth/connect' do
  redirect Instagram.authorize_url(redirect_uri: CALLBACK_URL)
end

get '/oauth/callback' do
  response = Instagram.get_access_token(params[:code], redirect_uri: CALLBACK_URL)
  session[:access_token] = response.access_token
  redirect '/auth'
end

get '/auth' do
  new_client
  user = @client.user
  @html = "<h1>auth</h1>"
  for media_item in @client.user_recent_media
    @html << "<img src='#{media_item.images.standard_resolution.url}'>"
  end
  erb :auth
end

get '/tags' do
  new_client
  tag = params[:tag]
  @html = "<h1> #{tag} </h1>"
  for media_item in @client.tag_recent_media(tag)
    @html <<"<img src='#{media_item.images.standard_resolution.url}"
  end
  erb :index
end

get '/user_search' do
  new_client
  name = params[:username]
  @html = "<h1></h1>"
  for user in @client.user_search(name)
    @html <<"<img src='#{user.profile_picture}'><h1>'#{user.username}'</h1>"
  end
  erb :index
end

get '/location_search' do
  new_client
  lat = params[:lat]
  long = params[:long]
  radius = params[:radius]
  @html = "<h1></h1>"
  for location in @client.location_search("#{lat}}", "#{long}", "#{radius}")
    loc_id = location.id
    for media_item in @client.location_recent_media(loc_id)
      @html <<"<img src='#{media_item.images.standard_resolution.url}'>"
      @html << "<li> #{location.name} <a href='https://www.google.com/maps/preview/@#{location.latitude},#{location.longitude},19z'>Map</a></li>"
    end
  end
  erb :index
end
