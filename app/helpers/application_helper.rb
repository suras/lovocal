module ApplicationHelper
  def get_image(cat)
    if(cat.image.present?)
      return "<img class='rs' src=#{cat.image.url}/>"
    else
      ""
    end
  end
end
