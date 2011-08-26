require 'sinatra'
require 'datamapper'
require 'monittr'
require 'haml'

require "#{Dir.pwd}/models/cluster"


class MonitMonit < Sinatra::Base

  # Setup
  DataMapper::setup(:default, "sqlite3://#{Dir.pwd}/db/monit_monit.db")
  Cluster.auto_upgrade!

  #Manage settings
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

  # Display overviews of server resource usage
  # Display a listing of servers
  get '/' do

  end

  # Display broken-down server resource and process information
  get '/:server_id' do

  end


  run!
end

