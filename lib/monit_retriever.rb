$LOAD_PATH.unshift(Dir.pwd + '/models') unless $LOAD_PATH.include?(Dir.pwd + '/models')
$LOAD_PATH.unshift(Dir.pwd + '/lib') unless $LOAD_PATH.include?(Dir.pwd + '/lib')

require "monit_job"
require 'rufus/scheduler'
require 'datamapper'
require 'server'

class MonitRetriever
  attr_accessor :jobs
  attr_accessor :scheduler

  def initialize
    self.jobs = []
    self.scheduler = Rufus::Scheduler.start_new
  end

  def start
    #Start a new job for each server? Or just one to handle all of them?
    Server.all.each do |server|
      self.jobs << scheduler.every('1m', MonitJob.new(server.id))
    end
    self
  end

  def stop
    self.jobs.each { |j| self.scheduler.unschedule(j.job_id) }
  end
end

