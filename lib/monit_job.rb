$LOAD_PATH.unshift(Dir.pwd + '/models') unless $LOAD_PATH.include?(Dir.pwd + '/models')
$LOAD_PATH.unshift(Dir.pwd + '/lib') unless $LOAD_PATH.include?(Dir.pwd + '/lib')

require 'datamapper'
require "server"

class MonitJob
  attr_accessor :server_id

  def initialize(server_id)
    self.server_id = server_id
  end

  def call(job)
    begin
      puts "RETRIEVING MONIT FOR #{server.id}"
      Server.get(server_id).fetch
  rescue Exception => e
      puts "MONIT ERROR FOR SERVER #{server_id} (#{e.message})"
    end
  end
end

