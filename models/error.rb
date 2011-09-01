class Error
  include DataMapper::Resource

  property :id, Serial
  property :message, Text
  property :created_at, DateTime

  belongs_to :server

end

