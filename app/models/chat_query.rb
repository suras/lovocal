class ChatQuery
  include Mongoid::Document

  field :query_title, type: String
  field :query_category, type: String


  belongs_to :user
  has_many   :chats

end
