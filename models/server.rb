require 'rest-client'
require 'nokogiri'
require 'timeout'

class Server
  include DataMapper::Resource
  include XMLHelpers
  
  property :id, Serial, :required => true
  property :name, String, :required => true
  property :url, String, :required => true
  property :uptime, String
  
  has n, :resource_records, :child_key => [ :server_id ]
  
  has n, :filesystems
  has n, :processes, 'ServerProcess'
  has n, :hosts
  
  before :save, :clean_url

  #Get the CPU value - i.e. the latest resource record for this server
  def cpu
    self.resource_records.first(:order => [:created_at.desc], :fields => [:cpu])
  end
  
  #Get the memory value - i.e. the latest resource record for this server
  def memory
    self.resource_records.first(:order => [:created_at.desc], :fields => [:memory])
  end
  
  #Get the load vlaue - i.e. the latest resoruce record for this server
  def load
    self.resource_records.first(:order => [:created_at.desc], :fields => [:load])
  end
  
  #Get the swap value - i.e. the latest resource record for this server
  def swap
    self.resource_records.first(:order =>  [:created_at.desc], :fields => [:swap])
  end
  
  ## Retrieve XML file from Monit, and parse it for the information we need ##
  
  def fetch
    begin
      Timeout::timeout(1) do
        @xml = RestClient.get(self.url)
        
        #Update the server
        self.update!({
          :uptime => value('//server/uptime')
        })
        
        #Add a resource record for the retrieval
        self.resource_records << ResourceRecord.create!({
          :cpu => value('system/cpu/user', :to_f),
          :memory => value('system/memory/percent', :to_f),
          :load => value('system/load/avg01', :to_f),
          :swap => value('system/swap/percent', :to_f)
        })
        
        #Update filesystems
        @xml.xpath("//service[@type=0]").map do |xml|
          Filesystem.update_or_create_from_xml({:name => value('name', xml), :server_id => self.id}, xml, {:server => self})
        end
        
        #Update processes
        @xml.xpath("//service[@type=3]").map do |xml|
          Process.update_or_create_from_xml({:name => value('name', xml), :server_id => self.id}, xml, {:server => self})
        end
        
        #Update hosts
        @xml.xpath("//service[@type=4]").map do |xml|
          Host.update_or_create_from_xml({:name => value('name', xml), :server_id => self.id}, xml, {:server => self})
        end
      end
      @server
    rescue Timeout::Error
      nil
    end
  end

  private
  
  def clean_url
    return unless self.url #This will be caught by validation, a URL is required
    self.url += "/_status?format=xml" unless url =~ /\/_status\?format=xml$/
  end
  
end
