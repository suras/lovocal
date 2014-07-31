class Api::V1::ChatController < Api::V1::BaseController
  before_filter :authenticate_user!

 # POST /chat
  def send_message
    ampq(params[:chat])
  end

  def ampq(params)
    EM.next_tick {
      connection = AMQP.connect(:host => '127.0.0.1', :user=>Rails.application.secrets.rabbitmq_user, :pass => Rails.application.secrets.rabbitmq_password, :vhost => "/")
      AMQP.channel ||= AMQP::Channel.new(connection)
      channel  = AMQP.channel
      channel.auto_recovery = true
      begin
        hash_obj = Chat.set_message(params)
        sender = hash_obj[:sender_obj]
        receiver = hash_obj[:receiver_obj]
        no_error = hash_obj[:no_error]
        chat_hash = {
        message: hash_obj[:message], chat_id: hash_obj[:chat_id], 
        list_cat_id: params[:list_cat_id], chat_query_id: hash_obj[:chat_query_id],
        server_sent_time: Time.now, chat_query_message: hash_obj[:chat_query_message],
        sender: {sent_time: params[:sent_time], sender_type: params[:sender_type],
        sender_id: params[:sender_id], sender_image: sender.image_url, 
        sender_name: sender.name}, receiver: {receiver_image: receiver.image_url, 
        receiver_name: receiver.name, receiver_type: params[:receiver_type],
        receiver_id: params[:receiver_id]}      
                }  
      rescue => e
        no_error = false
        params[:message] = "something went wrong. unable to send chat error: #{e}"
        chat_hash = params
      end
      if(no_error)
        receiver_exchange = channel.fanout(receiver.id.to_s+"exchange")
        receiver_exchange.publish(chat_hash.to_json)
        if(params[:receiver_type].downcase == "user" && receiver.online?)
           PrivatePub.publish_to "/messages/#{receiver.id.to_s}", :chat => chat_hash
        end
      end
      sender_exchange = channel.fanout(sender.id.to_s+"exchange") 
      sender_exchange.publish(chat_hash.to_json)
      if(params[:sender_type].downcase == "user")
        PrivatePub.publish_to "/messages/#{sender.id.to_s}", :chat => chat_hash
      end
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
    @sent_time = params[:chat][:sent_time]
    @distance = 50
    @services = Service.get_services_for_chat(@latitude, @longitude, @distance, @list_cat_id, @user_id)
    if(@services.blank?)
      render json: {error_message: "no services or u have messaged all the existing services"}, status: Code[:status_error]
    else
      @user_chat_query = ChatQuery.create(query_title: @message, query_category: @list_cat_id)
      send_service_messages
      render json: {}
    end
  end

  def send_service_messages
    @services.each do |service|
      params =  Hash.new
      params[:chat] = {}
      params[:chat][:message] = @message
      params[:chat][:sender_id] = @user_id
      params[:chat][:sender_type] = "user"
      params[:chat][:receiver_id] = service.id.to_s
      params[:chat][:receiver_type] = "service"
      params[:chat][:chat_id] = ""
      params[:chat][:list_cat_id] = @list_cat_id
      params[:chat][:sent_time] = @sent_time
      params[:chat][:chat_query_id] = @user_chat_query.id.to_s
      ampq(params[:chat])
    end
  end

  # POST /chat/user_chat_block
  def user_chat_block
     UserChatBlock.where(service_id: params[:chat][:service_id], user_id: current_user.id.to_s).first_or_create!
    render json: {}
  rescue => e
     render json: {error_code: Code[:error_rescue], error_message: e.message}, status: Code[:status_error]
  end

  # POST /chat/service_chat_block
  def service_chat_block
    service = current_user.services.find(params[:chat][:service_id])
    ServiceChatBlock.where(user_id: params[:user_id], service_id: service.id.to_s).first_or_create!
    render json: {}
  rescue => e
     render json: {error_code: Code[:error_rescue], error_message: e.message}, status: Code[:status_error]
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
