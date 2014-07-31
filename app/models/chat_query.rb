class ChatQuery
  include Mongoid::Document

  field :query_title
  field :query_category


  belongs_to :user
  has_many   :chats

end
