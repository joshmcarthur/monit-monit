class Host
  include DataMapper::Resource
  include XMLHelpers
  
  property :id, Serial
  property :name, String, :required => true
  property :response_time, Integer
  
  belongs_to :server
  
  def self.update_or_create_from_xml(conditions = {}, xml, extra_attributes)
    @xml = xml
    @host = Host.get(conditions) || Host.new
    @host.update({
      :response_time => value('port/responsetime')
    }.merge(extra_attributes))
    return @host
  end
end
