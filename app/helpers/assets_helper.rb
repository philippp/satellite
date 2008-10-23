module AssetsHelper

  def asset_tag(asset, options = {}, autostart = "no")
    return "" unless asset
    if options[:embed_params]
      options.delete(:embed_params)
      options = options.merge( {:a_filename => asset.public_filename, :a_title => asset.title } )
      if asset.is_audio?
        options = options.merge({ :a_type => "audio"})
      else
        options = options.merge({ :a_type => "image"})
      end
    end
    if options[:size]
      options = options.merge({:class => "asset #{options[:size].to_s}"})
    end
    options[:alt] = asset.page_title if asset.respond_to?(:page_title)

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
