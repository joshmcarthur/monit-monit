require 'sinatra'
require 'datamapper'
require 'monittr'
require 'haml'

require "#{Dir.pwd}/models/cluster"
require "#{Dir.pwd}/lib/monittr_decorator.rb"


class MonitMonit < Sinatra::Base

  # Setup
  DataMapper::setup(:default, "sqlite3://#{Dir.pwd}/db/monit_monit.db")
  Cluster.auto_upgrade!
  set :public, "public"

  # Overview
  get '/' do
    @servers = Cluster.servers
    haml :overview
  end

  # Show a specific server's details
  get '/servers' do
    @servers = Cluster.servers
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
end

