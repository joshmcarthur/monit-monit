class Alert
  include DataMapper::Resource
  
  property :id, Serial
  property :date, DateTime
  property :action, String
  property :description, Text
  
  belongs_to :server
end
