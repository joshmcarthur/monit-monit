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
    @resource ||= Monittr::Cluster.new([self.monit_url]) if self.monit_url
    self.resource = @resource
  end
  
  def self.servers 
    Cluster.all.map { |cluster| cluster.resource.servers }.flatten
  end

end

