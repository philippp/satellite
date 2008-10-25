module AssetsHelper

  # this is used to show the context of where you are viewing assets
  # so if you come from photos/index vs albums/show it can show a back link 
  def context
    if defined? @album
      "a_#{@album.id}"
    else
      :all
    end
  end

  # todo: get rid of all of this code
  def asset_tag(asset, options = {}, autostart = "no")
    return "" unless asset
    if options[:size]
      options = options.merge({:class => "asset #{options[:size].to_s}"})
    end
    if asset.respond_to?(:page_title)
      options[:alt] = asset.page_title
    end

    options = options.merge({:asset_id => asset.id})
    if asset.public_filename.include? "mp3"
      asset_tag_audio(asset, options, autostart)
    else
      img_size = options[:size]
      options = options.merge(asset_size(asset,img_size ) )

      # if !asset.downloaded and asset.hotlinks and asset.hotlinks.length > 0
      #   options = options.merge({:style => "display: none;"})
      #   options = options.merge({:onload => "resize_asset(this);"})
      # else
        options = options.merge({:class => "asset #{img_size} local_file" })
      # end

      filepath = asset.cachebusted_filename(img_size)
      image_tag(filepath, options)
    end
  end
  
  def asset_size(asset, size = nil)
    if asset.width and asset.height
      {:width => asset.width_guess(size), :height => asset.height_guess(size)}
    else
      { }
    end
  end

end
