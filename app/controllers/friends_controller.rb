class FriendsController < ApplicationController

  before_filter :load_friends, :only => [:index]
  before_filter :load_friend, :only => [:show, :update, :edit, :destroy]

  def index
  end

  def show
  end

  def new
  end
  
  def edit
  end
  
  
  def update
  end

  def create
  end

  def destroy
  end
  
  #########
  protected
  #########
  
  def load_friend 
    friend_id = params[:friend_id] || params[:id] || (raise "id not specified")
    @friend = Friend.find(friend_id)
  end

  def load_friends
    @friends = Friend.find(:all)
  end
  
end
