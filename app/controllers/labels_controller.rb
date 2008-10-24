class LabelsController < ApplicationController
  
  
  def create

    @label = Label.new(:x => params["x"],
                       :y => params["y"],
                       :asset => @user_asset)

    assign_user = logged_in? ? current_user : @user
    name = logged_in? ? params[:friend][:name] : params["friend_name_label_#{params[:asset_id]}"]

    @friend = Friend.lookup_or_create_by_name(name, assign_user, !logged_in?)

    @label.send_notification = false if @friend.profile

    @label.friend = @friend
    @label.user = assign_user

    respond_to do |format|
      if @label and @label.save
        if logged_in?
          create_friendnews( current_user, @user_asset, @label )
          service_push if @friend.profile and @friend.profile.user
        end
        flash_w_js :notice, 'Label was successfully created.'
        format.html { redirect_to user_asset_label_url(@label) }
        format.xml  { head :created, :location => label_url(@label) }
        format.js
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @label.errors.to_xml }
        format.js
      end
    end
  end


  def index
  end

end
