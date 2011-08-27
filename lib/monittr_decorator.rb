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
  
  def initialize(url, xml)
    @url = url
    @xml = Nokogiri::XML(xml)
    if error = @xml.xpath('error').first
      @error = Error.new({
        :name => error.attributes['name'].content,
        :message => error.attributes['message'].content,
        :status => 3
      })
      
      @system = nil
      @filesystems = []
      @processes = []
      @hosts = []
    else
      @system = Services::System.new(@xml.xpath("//service[@type=5]").first)
      @filesystems = @xml.xpath("//service[@type=0]").map do |xml|    
        Services::Filesystem.new(xml)
      end
      
      @processes = @xml.xpath("//service[@type=3]").map do |xml| 
        Services::Process.new(xml)
      end
      
      @hosts = @xml.xpath("//service[@type=4]").map do |xml| 
        Services::Host.new(xml)
      end
    end
  end
end
