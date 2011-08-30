require "#{Dir.pwd}/lib/monit_retriever"

class SchedulerManagerMiddleware
  class <<self
    attr_accessor :retriever
  end

  def initialize(app)
    @app = app
  end

  def call(env)
    start_retriever_if_necessary!
    @app.call(env)
  end

  protected

  def start_retriever_if_necessary!
    SchedulerManagerMiddleware.retriever ||= begin
      puts "STARTING RETRIEVER"
      MonitRetriever.new.start
    end
    add_finalizer_hook!
  end

  def add_finalizer_hook!
    at_exit do
      puts "STOPPING RETRIEVER"
      SchedulerManagerMiddleware.retriever.finish
    end
  end

end

