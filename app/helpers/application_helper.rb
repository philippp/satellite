module ApplicationHelper
  include SemanticFormHelper
  include PageMothHelper
  include TableMoth

  def user_path(user)
    if user.domain?
      url_for(:host => user.domain, :port => request.port, :controller => :users, :action => :show)
    else
      url_for(:controller => :users, :action => :show, :subdomain => user.login, :port => request.port)
    end
  end

  def is_owner?
    current_user == @user
  end

end
