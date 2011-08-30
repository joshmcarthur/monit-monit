require 'host'
require 'xml_helpers'

class Host
  include DataMapper::Resource
  include XMLHelpers

  property :id, Serial
  property :name, String, :required => true
  property :response_time, Integer

  belongs_to :server

  def self.update_or_create_from_xml(conditions = {}, xml, extra_attributes)
    @xml = xml

    attributes = {
      :name => value('name'),
      :response_time => value('port/responsetime')
    }.merge(extra_attributes)

    if @host = Host.get(conditions)
      @host.update!(attributes)
    else
      @host = Host.create!(attributes)
    end

    return @host
  end
end

