class IncomingMailProcessor

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

  def self.receive(message, params)
    #Prevents matching of 'successful' messages
    return unless message.split('\n')[0] =~ /matched/
  end
end
