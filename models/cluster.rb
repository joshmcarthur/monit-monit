class Cluster
  include DataMapper::Resource
  attr_writer :resource

  property :id, Serial
  property :name, String, :required => false
  property :monit_url, String, :required => true

  def connected?
    return self.resource ? self.resource.status : "Not connected"
  end

  def resource
   Monittr::Cluster.new([self.monit_url]) if self.monit_url
  end

  def self.servers
    Cluster.all.map { |cluster| cluster.resource.servers }.flatten
  end

  def self.server_information
    self.servers.map do |server|
      {
        :id => server.id,
        :cpu => server.system.cpu,
        :memory => server.system.memory,
        :load => server.system.load,
        :uptime => server.system.uptime
      }
    end
  end
end

