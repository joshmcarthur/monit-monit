require 'rubygems'
require 'bundler/setup'
require 'datamapper'

class DataStore
  def self.fetch_data_store(environment = :default)
    return case environment
    when :default
      DataMapper::setup(:default, "sqlite3://#{Dir.pwd}/db/monit_monit.db")
    when :test
      DataMapper::setup(:default, "sqlite3::memory")
    end
  end
end

