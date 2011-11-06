require 'sinatra'
require 'sinatra/content_for'
require 'datamapper'
require 'dm-timestamps'
require 'haml'
Dir[File.join(File.dirname(__FILE__), 'lib', '*.rb')].each do |file|
  require file
end

#Require models
$LOAD_PATH.unshift(File.dirname(__FILE__) + '/models') unless $LOAD_PATH.include?(File.dirname(__FILE__) + '/models')
require "xml_helpers"
require "server"


class MonitMonit < Sinatra::Base

  # Setup
  use SchedulerManagerMiddleware
  enable :sessions

  configure :test do
    DataStore.fetch_data_store(:test)
    DataMapper.auto_migrate!
  end

  configure :development do
    DataStore.fetch_data_store(:default)
    DataMapper.auto_upgrade!
  end

  helpers Sinatra::ContentFor
  set :public, "public"

  # Overview
  get '/' do
    @title = "Overview"
    @servers = Server.all
    @default_layout = params[:projector] == "true" ? :projector : :layout
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
  
  ### HANDLE INCOMING ALERTS ###
  def self.mailman_pop3_config
    YAML.load(
      File.read(
        File.join(File.dirname(__FILE__), "config", "mailing.yml")
      )
    )[settings.environment.to_s].symbolize_keys
  end
  
  Mailman.config.pop3 = MonitMonit.mailman_pop3_config
  Mailman::Application.run do
    to MonitMonit.mailman_pop3_config[:address],  IncomingMailProcessor
  end

end

