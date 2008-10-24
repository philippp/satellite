module ApplicationHelper
  include SemanticFormHelper
  include PageMothHelper
  include TableMoth

  def user_url(user)
    if user.domain?
      url_for(:host => user.domain, :port => request.port, :controller => :users, :action => :show)
    else
      if request.port != 80
        url_for(:controller => :users, :action => :show, :subdomain => user.login, :port => request.port)
      else
        url_for(:controller => :users, :action => :show, :subdomain => user.login)
      end
    end
  end

  def is_owner?
    current_user == @user
  end

  def page
    @page
  end

  def page_size
    @page_size || PAGE_SIZE || 16
  end

  def pager(item_count)
    page_max = (item_count.to_f/page_size).ceil
    delta = 3
    cssclass = "bar clearfix"

    url = "#{request.env["REQUEST_PATH"]}?"
    ret = "<div class=\"#{cssclass}\"><ul class=\"pager\">"

    if page > 1
      ret += "<li><a href=\"#{url}page=#{page - 1}\">Previous</a></li>"
    end

    if page_max.nil? or page_max > 1
      page_range = (page-delta)..(page+delta)
      ret += page_range.collect{ |x|
          if x == page and (page_max.nil? or x <= page_max)
            "<li class=\"current\"><a href=\"#{url}page=#{x}\">#{x}</a></li>"
          elsif x > 0 and (page_max.nil? or x <= page_max)
            "<li><a href=\"#{url}page=#{x}\">#{x}</a></li>"
          end}.join("")
    end

    if (page_max and page_max > 1 and page != page_max) or page_max.nil?
      ret += "<li><a href=\"#{url}page=#{page + 1}\">Next</a></li>"
    end

    ret += "</ul></div>"
  end


end
