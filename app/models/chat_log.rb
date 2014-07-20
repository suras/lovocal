class ChatLog
  include Mongoid::Document
  include Mongoid::Timestamps::Created
  include Mongoid::Timestamps::Updated

  field :is_seen, type: Boolend, default: false
  field :chat_id, type: String
  
  belongs_to :user
  belongs_to :service

  def self.save_log(params)
    viewer = Chat.get_chatter(params[:viewer_id], params[:viewer_type])
    chat_log = @viewer.chat_logs.where(chat_id: params[:chat_id]).first
    chat_log.is_seen = true
    chat_log.save!
  end

end
