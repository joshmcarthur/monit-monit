class Filesystem
  include DataMapper::Resource
  include XMLHelpers
  
  property :id, Serial
  property :percent, Float
  property :usage, Integer
  property :total, Integer
  
  belongs_to :server
  
  def self.update_or_create_from_xml(conditions, xml, extra_attributes = {})
    @xml = xml
    @filesystem = Filesystem.get(conditions) || Filesystem.new
    @filesystem.update({
      :name => value('name'),
      :percent => value('block/percent'),
      :usage => value('block/usage'),
      :total => value('block/total')
    }.merge(extra_attributes))
    return @filesystem
  end
end
