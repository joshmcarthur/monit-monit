require 'open-uri'
require 'nokogiri'
require 'timeout'

require 'filesystem'
require 'resource_record'
require 'server_process'
require 'host'
require 'xml_helpers'

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

  #Get the CPU value - i.e. the latest resource record for this server
  def cpu
    self.resource_records.first(:order => [:created_at.desc]).cpu
  end

  #Get the memory value - i.e. the latest resource record for this server
  def memory
    self.resource_records.first(:order => [:created_at.desc]).memory
  end

  #Get the load vlaue - i.e. the latest resoruce record for this server
  def load
    self.resource_records.first(:order => [:created_at.desc]).load
  end

  #Get the swap value - i.e. the latest resource record for this server
  def swap
    self.resource_records.first(:order =>  [:created_at.desc]).swap
  end

  def self.overview
    overview = []
    Server.all.each do |server|
      overview << {
        :id => server.id,
        :name => server.name,
        :uptime => server.uptime,
        :cpu => server.cpu.to_f,
        :memory => server.memory.to_f,
        :load => server.load.to_f
      }
    end
    overview
  end

  ## Retrieve XML file from Monit, and parse it for the information we need ##

  def fetch
    begin
      Timeout::timeout(60) do
        @xml = Nokogiri::HTML(open(self.monit_url))

        #Update the server
        self.update!({
          :uptime => value('//server/uptime')
        })

        #Add a resource record for the retrieval
        self.resource_records.create!({
          :cpu => value('//system/cpu/user', :to_f),
          :memory => value('//system/memory/percent', :to_f),
          :load => value('//system/load/avg01', :to_f),
          :swap => value('//system/swap/percent', :to_f),
        })

        #Update filesystems
        @xml.xpath("//service[@type=0]").map do |xml|
          Filesystem.update_or_create_from_xml({:name => value('name', :to_s, xml), :server_id => self.id}, xml, {:server => self})
        end

        #Update processes
        @xml.xpath("//service[@type=3]").map do |xml|
          ServerProcess.update_or_create_from_xml({:name => value('name', :to_s, xml), :server_id => self.id}, xml, {:server => self})
        end

        #Update hosts
        @xml.xpath("//service[@type=4]").map do |xml|
          Host.update_or_create_from_xml({:name => value('name', :to_s, xml), :server_id => self.id}, xml, {:server => self})
        end
      end
      self
    end
  end


  def monit_url
    return unless self.url #This will be caught by validation, a URL is required
    monit_url = self.url
    monit_url += "/_status?format=xml" unless url =~ /\/_status\?format=xml$/
    monit_url
  end

end

