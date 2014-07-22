class Chat
  include Mongoid::Document
  include Mongoid::Timestamps::Created
  include Mongoid::Timestamps::Updated

  field :message, type: String
  field :sender_type, type: String
  field :sender_id, type: String
  field :receiver_type, type: String
  field :receiver_id, type: String
  field :listing_category, type: String


  def self.save_chat(params)
  	sender = Chat.get_chatter(params[:sender_id], params[:sender_type])
  	receiver = Chat.get_chatter(params[:receiver_id], params[:receiver_type])
   chat =  Chat.create!(message: params[:message], sender_id: sender.id.to_s, 
    	 receiver_id: receiver.id.to_s, sender_type: sender.class.to_s,
    	 receiver_type: receiver.class.to_s)
    Chat.save_chat_logs_and_response(sender, receiver, chat.id.to_s, params[:reply_id], params[:list_cat_id])
    return {sender_id: sender.id.to_s, receiver_id: receiver.id.to_s,
     chat_id: chat.id.to_s}  
  end

  def self.save_chat_logs_and_response(sender, receiver, chat_id, reply_id, list_cat_id)
    receiver_log = receiver.chat_logs.where(chat_id: chat_id).first_or_create!
    # sender_log = sender.chat_logs.where(chat_id: chat_id).first_or_create!
    if(sender.class.to_s == "User")
       sender.user_chat_logs.where(service_id: receiver.id.to_s, list_cat_id: list_cat_id).first_or_create!
    else
        res_log = sender.chat_response_logs.where(chat_id: reply_id).first
      if(res_log.present?)
        res_log.responded = true 
        res_log.save
      end
    end
    if(receiver.class.to_s == "Service")
      receiver.chat_response_logs.create(chat_id: chat_id)
    end
  end

  def self.can_send_chat(sender_id, sender_type, receiver_id, receiver_type)
    if sender_type.downcase == "service"
      chat = UserChatBlock.where(service_id: sender_id).first
      if(chat.present?)
        return {can_send: false, messssage: "You can only reply to use queries"}
      else
        ServiceChatBlock.where(user_id: sender_id).first.destroy
        return {can_send: true, messssage: ""}
      end
    elsif(sender_type.downcase == "user")
      chat = ServiceChatBlock.where(user_id: sender_id).first
      if(chat.present?)
        return {can_send: false, messssage: "The service is not present in chat"}
      else
        UserChatBlock.where(service_id: sender_id).first.destroy
        return {can_send: true, messssage: ""}
      end
    end
  end

  def self.get_chatter(id, type)
    if(type.downcase == "user")
      return User.find(id)
    elsif(type.downcase == "service")
      return Service.find(id)
    else
      raise "no chatter found"
    end
  
  end

end
