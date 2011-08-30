require 'sinatra'
require 'sinatra/content_for'
require 'datamapper'
require 'dm-timestamps'
require 'haml'

#Require models
require "#{Dir.pwd}/models/xml_helpers"
Dir["#{Dir.pwd}/models/*.rb"].each { |model| require model }


class MonitMonit < Sinatra::Base

  # Setup
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
    @servers.each { |s| s.fetch }
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
    redirect '/servers'
  end

  post '/servers/:id/delete' do
    @server = Server.get(params[:id])
    @server.destroy
    redirect '/servers'
  end

end

