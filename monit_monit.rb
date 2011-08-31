require 'sinatra'
require 'sinatra/content_for'
require 'datamapper'
require 'dm-timestamps'
require 'haml'
require "#{Dir.pwd}/lib/scheduler_manager_middleware"

#Require models
$LOAD_PATH.unshift(File.dirname(__FILE__) + '/models') unless $LOAD_PATH.include?(File.dirname(__FILE__) + '/models')
require "xml_helpers"
require "server"


class MonitMonit < Sinatra::Base

  # Setup
  use SchedulerManagerMiddleware
  
  configure :test do
    DataMapper::setup(:default, "sqlite3::memory")
    DataMapper.auto_migrate!
  end
  
  configure :development do
    DataMapper::setup(:default, "sqlite3://#{Dir.pwd}/db/monit_monit.db")
    DataMapper.auto_upgrade!
  end
  
  helpers Sinatra::ContentFor
  set :public, "public"

  # Overview
  get '/' do
    @title = "Overview"
    @servers = Server.all
    haml :overview
  end

  get '/overview.json' do
    @servers = Server.overview.to_json
  end

  # Show a selection page for servers details
  get '/server-detail/:id' do
    @server = Server.get(params[:id])
    pass unless @server
    @title = @server.name if @server
    haml :detail
  end

  #Manage servers
  get '/servers' do
    @servers = Server.all
    @title = "Servers"
    haml :servers
  end

  post '/servers' do
    @server = Server.create!(params[:server])
    @server.fetch
    redirect '/servers'
  end

  post '/servers/:id/delete' do
    @server = Server.get(params[:id])
    @server.destroy
    redirect '/servers'
  end

  not_found do
    @title = "404"
    haml :"404", {:layout => :blank}
  end

  error do
    @title = "500"
    haml :"500", {:layout => :blank}
  end

end

