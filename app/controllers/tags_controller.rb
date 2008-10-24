class TagsController < ApplicationController
  
  before_filter :load_user_asset
  
  def create
    @tag = Tag.new(:x => params[:x],
                   :y => params[:y],
                   :asset => @user_asset);
    
    name = params[:friend][:name]

    @friend = Friend.lookup_or_create_by_name(name)

    @tag.friend = @friend

    respond_to do |format|
      if @tag and @tag.save
        format.js   { render(:update){ |page|
            page << "photo_tagger.tags=#{@user_asset.reload.tags.to_json};"
            page << "photo_tagger.reload_tags();"
            page << "photo_tagger.show_tags();"
            page << "photo_tagger.cancelForm();"
            page["create-tag-response"].update("Created tag for #{@friend.name}")

          }}
      else
        
        err_msg = "Couldn't create tag"
        if @tag.errors[:asset_id]
          err_msg = "There's already a tag for #{@friend.name} here"
        end
        format.js   { render(:update) { |page|
            page["create-tag-response"].update(err_msg)
           
          }}
      end
    end

  end

  def index
  end
  
  def load_user_asset
    @user_asset = Asset.find(params[:user_asset_id] || params[:asset_id]) or raise ActiveRecord::RecordNotFound
    @asset = @user_asset # apparently there is a lot of stupid code assuming we have both an @asset and @user_asset
  end


end
