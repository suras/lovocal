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
 
  belongs_to :chat_query
  belongs_to :user
  belongs_to :service

  def self.set_message(params)
     can_send_chat = Chat.can_send_chat(params[:sender_id],params[:sender_type],
                              params[:receiver_id], params[:receiver_type])
    if(can_send_chat[:can_send])
       chat = Chat.save_chat(params)  
       chat_id = chat[:chat_id]
       no_error = true
     else
       chat_id = ""
       no_error = false
       params[:message] = can_send_chat[:message]
     end
    return  { message: params[:message], chat_id: chat_id,sender_obj: chat[:sender_obj], 
            receiver_obj: chat[:receiver_obj], no_error: no_error,
            chat_query_id: chat[:chat_query_id], chat_query_message: chat[:chat_query_message] }  
  end
  
  def self.save_chat(params)
  	sender = Chat.get_chatter(params[:sender_id], params[:sender_type])
  	receiver = Chat.get_chatter(params[:receiver_id], params[:receiver_type])
    raise "Chatter not found" unless sender.present? && receiver.present?
    chatter = get_chatter_ids(sender, receiver)
    user_id = chatter[:user_id]
    service_id = chatter[:service_id]
    chat =  Chat.create!(message: params[:message], sender_id: sender.id.to_s, 
    	 receiver_id: receiver.id.to_s, sender_type: sender.class.to_s,
    	 receiver_type: receiver.class.to_s, user_id: user_id, service_id: service_id)
    if(params[:chat_query_id].present?)
      chat_query = ChatQuery.where(_id: params[:chat_query_id]).first
      return unless chat_query
      chat.chat_query_id = BSON::ObjectId.from_string(params[:chat_query_id])
      chat.save
      chat_query_message = chat_query.query_title
    else
      params[:chat_query_id] = ""
      chat_query_message = ""
    end
    Chat.save_chat_logs_and_response(sender, receiver, chat.id.to_s, params[:reply_id], params[:list_cat_id])
   {sender_obj: sender, receiver_obj: receiver, chat_query_id: params[:chat_query_id],
     chat_id: chat.id.to_s, chat_query_message: chat_query_message}
  rescue => e
    raise "something went wrong #{e}"  
  end

  def self.save_chat_logs_and_response(sender, receiver, chat_id, reply_id, list_cat_id)
    receiver_log = receiver.chat_logs.where(chat_id: chat_id).first_or_create!
    # sender_log = sender.chat_logs.where(chat_id: chat_id).first_or_create!
    if(sender.class.to_s == "User")
       u_log = sender.user_chat_logs.where(service_id: receiver.id.to_s, list_cat_id: list_cat_id).first_or_create!
       u_log.send_status = false
       u_log.save
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
        ServiceChatBlock.where(user_id: sender_id).first.try(:destroy)
        return {can_send: true, messssage: ""}
      end
    elsif(sender_type.downcase == "user")
      chat = ServiceChatBlock.where(user_id: sender_id).first
      if(chat.present?)
        return {can_send: false, messssage: "The service is not present in chat"}
      else
        UserChatBlock.where(service_id: sender_id).first.try(:destroy)
        return {can_send: true, messssage: ""}
      end
    end
  rescue => e
    raise "something went wrong #{e}" 
  end

  def self.get_chatter_ids(sender, receiver)
    if(sender.class.to_s.downcase == "user")
      user_id = sender.id
      service_id = receiver.id
    else
      user_id = receiver.id
      service_id = sender.id
    end
    if(receiver.class.to_s.downcase == "user")
      user_id = receiver.id
      service_id = sender.id
    else
      user_id = sender.id
      service_id = receiver.id
    end
    return {user_id: user_id, service_id: service_id}
  end

  def self.get_chatter(id, type)
    if(type.downcase == "user")
      return User.where(_id: id).first
    elsif(type.downcase == "service")
      return Service.where(_id: id).first
    else
      raise "no chatter found"
    end
  end


  def self.chatter_details(obj, type)
    if(type == "user")
       if(obj.sender_type.downcase == "service") 
          sender_name = Service.where(_id: obj.sender_id).first.try(:business_name)
          entity = "other-chat"
       else
          sender_name = ""
          entity = "my-chat"
       end 
       return {sender_name: sender_name, entity: entity} 
    end
    # pending service
  end


end
