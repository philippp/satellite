class TagsController < ApplicationController
  
  before_filter :load_user_asset
  before_filter :load_tag, :only => [:destroy]
  def create
    @asset.reload
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
            page.replace_html "tag-list", :partial => "tag_list", :locals => { :asset => @asset}
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
  
  def destroy
    
    respond_to do |format|
    tag_id = @tag.id
      if @tag.destroy
        format.js   { render(:update){ |page|
            page.remove "tag-list-item-#{tag_id}" 
            page.remove "pt-tag-#{tag_id}"
          }
        }
      else
        format.js   { render(:update){ |page|
            page["tag-list-item-#{tag_id}"].update("Could not remove tag for #{tag.friend.name}") 
          }
        }
      end
    end
  end

  def index
  end
  
  def load_user_asset
    @user_asset = Asset.find(params[:user_asset_id] || params[:asset_id]) or raise ActiveRecord::RecordNotFound
    @asset = @user_asset # apparently there is a lot of stupid code assuming we have both an @asset and @user_asset
  end

  def load_tag
    tag_id = params[:id] || params[:tag_id] || (raise "id not specified")    
    @tag = Tag.find(params[:id]) || Tag.find(params[:tag_id]) 
  end

end
