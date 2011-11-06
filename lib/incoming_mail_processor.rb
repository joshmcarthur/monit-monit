$LOAD_PATH.unshift(Dir.pwd + '/models') unless $LOAD_PATH.include?(Dir.pwd + '/models')
$LOAD_PATH.unshift(Dir.pwd + '/lib') unless $LOAD_PATH.include?(Dir.pwd + '/lib')

class IncomingMailProcessor
  require 'mail'
  require 'datamapper'
  require 'server'
  
  # This class method is called when Mailman receives a message matching the configured
  # 'to' address for alerts. 
  # This parser is written to expect the following (default) Monit message:
  # Resource limit matched Service <% url %>
  #
  #     Date:        Mon, 10 Oct 2011 03:05:34 +1300
  #     Action:      alert
  #     Host:        <% host %>
  #     Description: '<% host %>' <% message %>
  #
  # Your faithful employee,
  # monit

  def receive(message, params)
    #Prevents matching of 'successful' messages
    contents = message.body.decoded
    contents = contents.split("\n")
    contents.delete_if { |c| c.blank? || c =~ /\A\-\-/ }
    require 'ruby-debug'
    debugger
    return unless contents[0] =~ /matched/
    service = contents[0].match(/Service\s{1}(\S+)/)[1]
    date    = Time.parse(contents[1].match(/Date\:\s+(.+)/)[1])
    action  = contents[3].match(/Action\:\s+(.+)/)[1]
    host    = contents[4].match(/Host\:\s+(.+)/)[1]
    description = contents[5].match(/Description\:\s+(.+)/)[1]
    
    @server = Server.get(:host => "http://#{host}")
    @server.alerts.first_or_create_by({:date => date}, {
      :action => action,
      :description => description
    })
  end
end
