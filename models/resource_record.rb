require 'dm-timestamps'

class ResourceRecord
  include DataMapper::Resource
  
  property :id, Serial
  property :cpu, Float, :required => true
  property :memory, Float, :required => true
  property :load, Float
  property :swap, Float
  property :created_at, DateTime
  
  belongs_to :server, :required => false
  belongs_to :process, 'ServerProcess', :required => false
end
