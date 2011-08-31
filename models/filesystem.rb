require 'server'
require 'xml_helpers'

class Filesystem
  include DataMapper::Resource
  include XMLHelpers

  property :id, Serial
  property :name, String
  property :percent, Float
  property :usage, String
  property :total, String

  belongs_to :server

  def self.update_or_create_from_xml(conditions, xml, extra_attributes = {})
    @xml = xml

    attributes = {
      :name => value('name'),
      :percent => value('block/percent'),
      :usage => value('block/usage'),
      :total => value('block/total')
    }.merge(extra_attributes)

    if @filesystem = Filesystem.first(conditions)
      @filesystem.update!(attributes)
    else
      @filesystem = Filesystem.create!(attributes)
    end
    return @filesystem
  end

  def self.value(selector, transformer = :to_s, xml = nil)
    (xml ? xml : @xml).xpath(selector).first.content.send(transformer) rescue nil
  end
end

