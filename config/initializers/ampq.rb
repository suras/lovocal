# require 'amqp'

module ThinEM
  def self.start
    EventMachine.next_tick do
      AMQP.channel ||= AMQP::Channel.new(AMQP.connect(:host => '127.0.0.1', :user=>Rails.application.secrets.rabbitmq_user, :pass => Rails.application.secrets.rabbitmq_password, :vhost => "/"))
      channel = AMQP.channel
      puts "thin em started"
      s_exchange = channel.fanout("53cc0ae07375727a210a0000exchange")
      u_exchange = channel.fanout("53c7a4bf73757212770f0000exchange")
      u_queue = channel.queue("53c7a4bf73757212770f0000queue", :auto_delete => true).bind(u_exchange)
      s_queue = channel.queue("53cc0ae07375727a210a0000queue", :auto_delete => true).bind(s_exchange) 
      
      u_queue.subscribe do |payload|
        puts "Received a message: #{payload}. Disconnecting..."
        # connection.close { EventMachine.stop }
      end
      s_queue.subscribe do |payload|
        puts "Received a message: #{payload}. Disconnecting..."
        # connection.close { EventMachine.stop }
      end
    end
  end
end

module PassengerEM
  def self.start
    PhusionPassenger.on_event(:starting_worker_process) do |forked|
      # for passenger, we need to avoid orphaned threads
        if forked && EM.reactor_running?
          EM.stop
        end
        Thread.new {
          EM.run do
            AMQP.channel ||= AMQP::Channel.new(AMQP.connect(:host => '127.0.0.1', :user=>ENV["RABBITMQ_USERNAME"], :pass => ENV["RABBITMQ_PASSWORD"], :vhost => "/"))
          end
          }
        die_gracefully_on_signal
     end
  end
  

  def self.die_gracefully_on_signal
    Signal.trap("INT") { EM.stop }
    Signal.trap("TERM") { EM.stop }
  end
end

# if defined?(PhusionPassenger)
#   PassengerEM.start
# end

if defined?(Thin)
  ThinEM.start
end