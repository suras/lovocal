class Api::V1::ChatController < Api::V1::BaseController
  before_filter :authenticate_user!
  def set_message
     can_send_chat = Chat.can_send_chat(params[:chat][:sender_id],params[:chat][:sender_type],
                              params[:chat][:receiver_id], params[:receiver_type])
    if(can_send_chat[:can_send])
       @chat = Chat.save_chat(params[:chat])	
       @sender_id = @chat[:sender_id]  
       @receiver_id = @chat[:receiver_id]
       @chat_id = @chat[:chat_id]
     else
       @chat_id = ""
       @receiver_id = false
       params[:chat][:message] = can_send_chat[:message]
     end
     @chat_hash = {message: params[:chat][:message], chat_id: @chat_id, 
     	          sent_time: params[:chat][:sent_time], sender_type: params[:chat][:sender_type],
                  sender_id: params[:chat][:sender_id], receiver_id: params[:chat][:receiver_id],
                  receiver_type: params[:chat][:receiver_type], 
                  list_cat_id: params[:chat][:list_cat_id]
     	          }  
  end

  # def set_chat_params
  #   @message = params[:chat][:message]
  #   @sender_id = params[:chat][:sender_id]
  #   @sender_type = params[:chat][:sender_type]
  #   @receiver_id = params[:chat][:receiver_id]
  #   @receiver_type = params[:chat][:receiver_type]
  #   @list_cat_id = params[:chat][:list_cat_id]
  #   @sent_time = params[:chat][:sent_time]
  # end

  # POST /chat
  def send_message
    EM.next_tick {
      connection = AMQP.connect(:host => '127.0.0.1', :user=>Rails.application.secrets.rabbitmq_user, :pass => Rails.application.secrets.rabbitmq_password, :vhost => "/")
      AMQP.channel ||= AMQP::Channel.new(connection)
      channel  = AMQP.channel
      channel.auto_recovery = true
      set_message
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
    }
  end

  # POST /multiple_chats
  def send_multiple_chats
    @list_cat_id = params[:chat][:list_cat_id]
    @latitude = params[:chat][:latitude].to_f
    @latitude = params[:chat][:longitude].to_f
    @message = params[:chat][:message]
    @user_id = params[:chat][:user_id]
    @distance = 50
    @services = Service.get_services_for_chat(@latitude, @longitude, @list_cat_id, @user_id)
    if(@services.blank?)
      render json: {error_message: "no services or u have messaged all the existing services"}, status: Code[:status_error]
    else
      send_service_messages
      render json: {}
    end
  end

  def send_service_messages
    @services.each do |service|
      params =  Hash.new
      params[:chat] = {}
      params[:chat][:message] = @message
      params[:chat][:sender_id] = service.id
      params[:chat][:sender_type] = "service"
      params[:chat][:receiver_id] = @user_id
      params[:chat][:receiver_type] = "user"
      params[:chat][:chat_id] = ""
      params[:chat][:list_cat_id] = @list_cat_id
      send_message
    end
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
