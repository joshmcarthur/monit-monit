ENV['RACK_ENV'] = 'test'

require 'rubygems'
require 'bundler'

Bundler.require

require "#{Dir.pwd}/monit_monit"
require 'capybara'
require 'capybara/dsl'
require 'test/unit'

class MonitMonitTest < Test::Unit::TestCase
  include Capybara::DSL
  
  set :environment, :test
  set :run, false
  
  def setup
    Capybara.app = MonitMonit.new
  end
  
  def test_error_for_no_servers
    visit '/'
    within('div.alert-message.block-message.error') do
      assert page.has_content?('You need to set up at least one Monit server')
    end
  end
end
