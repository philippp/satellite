module RoutesHelper

  # this is because url_for isn't monkey patched to do this
  # url_for(:host => .., :path => false)

  def user_url(user)
    user.url(request)
  end

  def user_path(user)
    user_url(user)
  end

end
