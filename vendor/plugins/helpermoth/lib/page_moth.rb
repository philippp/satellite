module PageMoth

  def page
    @page ||= (params[:page] || 1).to_i

    # cleans bad data
    @page = 1 if @page.instance_of?(Fixnum) and @page < 1
    @page
  end

  def page_size
    PAGE_SIZE || 16
  end

  def page_offset
    (page - 1)*page_size
  end

end