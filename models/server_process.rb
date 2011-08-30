class ServerProcess
  include DataMapper::Resource
  
  property :id, Serial
  property :name, String
  property :pid, Integer
  property :uptime, Integer
  
  has n, :resource_records, :child_key => [ :process_id ]
  belongs_to :server
  
  
  def cpu
    self.resource_records.first(:order => [ :created_at.desc ], :fields => [:cpu])
  end
  
  def memory
    self.resource_records.first(:order => [ :created_at.desc ], :fields => [:memory])
  end
  
  def self.update_or_create_from_xml(conditions, xml, extra_attributes = {})
    @xml = xml
    @process = Process.get(conditions) || Process.new
    @process.update({
      :pid => value('pid'),
      :uptime => value('uptime')
    }.merge(extra_attributes))
    
    #Create a Resource Record for the process
    @process.resource_records.create({
      :cpu => value('cpu/percent'),
      :memory => value('memory/percent')
    })
    
    return @process
  end
end
