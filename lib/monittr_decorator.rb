class Monittr::Platform
  attr_accessor :kernel
  attr_accessor :architecture
  attr_accessor :num_cpus
  attr_accessor :total_memory
#
  def initialize(xml)
    self.kernel = xml.xpath("//release").first.content.to_s rescue nil
    self.architecture = (xml.xpath("//machine").first.content.to_s rescue "") =~ /_64/ ? "64-bit" : "32-bit"
    self.num_cpus = xml.xpath("//cpu").first.content.to_i rescue nil
    self.total_memory = xml.xpath("//memory").first.content.to_i rescue nil
  end
end

Monittr::Server.class_eval do

  class Error
    attr_accessor :name
    attr_accessor :message
    attr_accessor :status

    def initialize(attributes = {})
      self.name = attributes.fetch(:name, nil)
      self.message = attributes.fetch(:email, nil)
      self.status = attributes.fetch(:status, nil)
    end
  end

  attr_accessor :error
  attr_accessor :id
  attr_reader :platform

  def initialize(url, xml)
    @url = url
    @xml = Nokogiri::XML(xml)
    @id = @xml.xpath("/monit/server/id").first.content rescue nil
    if error = @xml.xpath('error').first
      @error = Error.new({
        :name => error.attributes['name'].content,
        :message => error.attributes['message'].content,
        :status => 3
      })

      @platform = nil
      @system = nil
      @filesystems = []
      @processes = []
      @hosts = []
    else
      @system = Monittr::Services::System.new(@xml.xpath("//service[@type=5]").first)
      @platform = Monittr::Platform.new(@xml.xpath("//platform").first)
      @filesystems = @xml.xpath("//service[@type=0]").map do |xml|
        Monittr::Services::Filesystem.new(xml)
      end

      @processes = @xml.xpath("//service[@type=3]").map do |xml|
        Monittr::Services::Process.new(xml)
      end

      @hosts = @xml.xpath("//service[@type=4]").map do |xml|
        Monitrr::Services::Host.new(xml)
      end
    end
  end


  private
  def id_from_url
    self.url.to_s.gsub("http://", "").gsub(/(:[0-9]+|[\/]{1}.*)/, "").gsub(/\W/, '_')
  end
end

