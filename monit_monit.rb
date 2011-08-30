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
  DataMapper::setup(:default, "sqlite3://#{Dir.pwd}/db/monit_monit.db")
  Server.auto_upgrade!
  ServerProcess.auto_upgrade!
  ResourceRecord.auto_upgrade!
  Host.auto_upgrade!
  Filesystem.auto_upgrade!

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
  get '/server-details' do
    @server = Server.get(params[:id])
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

end

