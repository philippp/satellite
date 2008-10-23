module ApplicationHelper
  include SemanticFormHelper

  def user_path(user)
    if user.domain?
      url_for(:host => user.domain, :port => request.port, :controller => :users, :action => :show)
    else
      url_for(:controller => :users, :action => :show, :subdomain => user.login, :port => request.port)
    end
  end

end
