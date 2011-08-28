require 'sinatra'
require 'sinatra/content_for'
require 'datamapper'
require 'monittr'
require 'haml'

require "#{Dir.pwd}/models/cluster"
require "#{Dir.pwd}/lib/monittr_decorator"


class MonitMonit < Sinatra::Base

  # Setup
  DataMapper::setup(:default, "sqlite3://#{Dir.pwd}/db/monit_monit.db")
  Cluster.auto_upgrade!
  helpers Sinatra::ContentFor
  set :public, "public"

  # Overview
  get '/' do
    @servers = Cluster.servers
    haml :overview
  end

  get '/overview.json' do
    @servers = Cluster.server_information.to_json
  end

  # Show a selection page for servers details
  get '/servers' do
    @server = Cluster.servers.select { |server| server.id == params[:id] }.first
    haml :servers
  end

  #Manage clusters
  get '/clusters' do
    @clusters = Cluster.all
    haml :clusters
  end

  post '/cluster' do
    @cluster = Cluster.create!(params[:cluster])
    redirect '/clusters'
  end

  post '/cluster/:id/delete' do
    @cluster = Cluster.get(params[:id])
    @cluster.destroy
    redirect '/clusters'
  end

  run!
end

