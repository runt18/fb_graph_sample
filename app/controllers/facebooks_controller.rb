class FacebooksController < ApplicationController
  before_filter :require_authentication, :only => :destroy

  # handle Facebook Auth Cookie generated by JavaScript SDK
  def show
    auth = Facebook.auth.from_cookie(cookies)
    authenticate Facebook.identify(auth.user)
    redirect_to dashboard_url
  end

  # handle Normal OAuth flow: start
  def new
    redirect_to Facebook.auth.client.web_server.authorize_url(
      :redirect_uri => callback_facebook_url,
      :scope => Facebook.config[:perms]
    )
  end

  # handle Normal OAuth flow: callback
  def create
    access_token = Facebook.auth.client.web_server.get_access_token(
      params[:code],
      :redirect_uri => callback_facebook_url
    )
    user = FbGraph::User.me(access_token).fetch
    authenticate Facebook.identify(user)
    redirect_to dashboard_url
  end

  def destroy
    current_user.destroy
    redirect_to root_url
  end

end
