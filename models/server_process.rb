require 'server'
require 'server_process'

class ServerProcess
  include DataMapper::Resource

  property :id, Serial
  property :name, String
  property :pid, Integer
  property :uptime, Integer

  has n, :resource_records, :child_key => [ :process_id ]
  belongs_to :server


  def cpu
    self.resource_records.first(:order => [ :created_at.desc ]).cpu
  end

  def memory
    self.resource_records.first(:order => [ :created_at.desc ]).memory
  end

  def self.update_or_create_from_xml(conditions, xml, extra_attributes = {})
    @xml = xml

    attributes = {
      :name => value('name'),
      :pid => value('pid'),
      :uptime => value('uptime')
    }.merge(extra_attributes)

    if @process = ServerProcess.first(conditions)
      @process.update!(attributes)
    else
      @process = ServerProcess.create(attributes)
    end

    #Create a Resource Record for the process
    @process.resource_records.create!({
      :cpu => value('cpu/percent'),
      :memory => value('memory/percent')
    })

    return @process
  end

  def self.value(selector, transformer = :to_s, xml = nil)
    (xml ? xml : @xml).xpath(selector).first.content.send(transformer) rescue nil
  end
end

