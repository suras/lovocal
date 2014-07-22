class Api::V1::ChatController < Api::V1::BaseController
  before_filter :authenticate_user!
  def set_message
     @chat = Chat.save_chat(params[:chat])	
     @sender_id = @chat[:sender_id]  
     @receiver_id = @chat[:receiver_id]
     @chat_id = @chat[:chat_id]
     @exchange = params[:exchange]
     @chat_hash = {message: params[:chat][:message], chat_id: @chat_id, 
     	          sent_time: params[:chat][:sent_time], sender_type: params[:chat][:sender_type],
                  sender_id: params[:chat][:sender_id], receiver_id: params[:chat][:receiver_id],
                  receiver_type: params[:chat][:receiver_type], 
                  listing_category: params[:chat][:listing_category]
     	          }  
  end

  # POST /chat
  def send_message
    EM.next_tick {
      set_message
      connection = AMQP.connect(:host => '127.0.0.1', :user=>Rails.application.secrets.rabbitmq_user, :pass => Rails.application.secrets.rabbitmq_password, :vhost => "/")
      AMQP.channel ||= AMQP::Channel.new(connection)
      channel  = AMQP.channel
      channel.auto_recovery = true
      
      if(@receiver_id)
        receiver_exchange = channel.fanout(@receiver_id+"exchange")
        receiver_exchange.publish(@chat_hash.to_json)
      end
      sender_exchange = channel.fanout(@sender_id+"exchange") 
      sender_exchange.publish(@chat_hash.to_json)
      connection.on_tcp_connection_loss do |connection, settings|
        # reconnect in 10 seconds, without enforcement
        connection.reconnect(false, 10)
      end
      connection.on_error do |conn, connection_close|
        puts <<-ERR
        Handling a connection-level exception.
        AMQP class id : #{connection_close.class_id},
        AMQP method id: #{connection_close.method_id},
        Status code   : #{connection_close.reply_code}
        Error message : #{connection_close.reply_text}
        ERR
       conn.periodically_reconnect(30)
      end
      EventMachine::error_handler { |e| puts "error! in eventmachine #{e}" }
        render json: {}
    }
  rescue => e
      Rails.logger.info "error! #{e}"
      render json: {error: "message not send"}, status: Code[:status_error]
  end

  # POST /chat/acknowledge
  def chat_acknowledge
    @chat = Chat.find(params[:chat][:chat_id]) 
    if(@chat)
      ChatLog.save_log(params[:chat])
    end
    render json: {}
  rescue => e
     render json: {error_code: Code[:error_rescue], error_message: e.message}, status: Code[:status_error]
  end

end
