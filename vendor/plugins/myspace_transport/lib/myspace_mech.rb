# MyspaceMech - Mechanizing Myspace so you don't have to. 
class MyspaceMech

  require 'openssl'
  require 'digest/sha1'
  require 'rubygems'
  require 'mechanize'
  require 'logger'

  @agent = nil
  @profile_owner_page = nil
  @friend_id = 0
  @@myspace_url = "http://www.myspace.com"

  def initialize(logfile = nil)
    Hpricot.buffer_size = 262144
    if logfile
      @agent = WWW::Mechanize.new { |a| a.log = Logger.new(logfile) }
    else
      @agent = WWW::Mechanize.new
    end
    # @agent.pluggable_parser.default = Hpricot
    @agent.user_agent_alias = 'Linux Mozilla'
  end

  def login(email, pass)
    page = @agent.get(@@myspace_url)
    login_form = page.forms.name("aspnetForm").first
    login_form.fields.collect! do |f|
      if f.name.include? "Email_Textbox"
        f.value = email
      end
      if f.name.include? "Password_Textbox"
        f.value = pass
      end
      f
    end
    profile_owner_page = @agent.submit(login_form)

    # Skip ad splashscreen if it exists
    ad_links = profile_owner_page.links.text(/skip this advertisement/i)
    profile_owner_page = ad_links.first.click if(ad_links.size > 0)

    return confirm_profile_owner_page(profile_owner_page)
  end

  def login?
    @profile_owner_page != nil
  end

    # Make sure we're in the owner's profile
  def confirm_profile_owner_page(profile_owner_page)
    if profile_owner_page.links.href(/fuseaction=user.editAlbums/).size > 0
      @profile_owner_page = profile_owner_page
      return true
    else
      return false
    end
  end

  # Encrypt a password with a secret key. 
  # (If you are going to store passwords, please wear protection.)
  def self.encrypt_pass(raw_pass, secret)
    c = OpenSSL::Cipher::Cipher.new("aes-256-cbc")
    c.encrypt
    # your pass is what is used to encrypt/decrypt
    c.key = key = Digest::SHA1.hexdigest(secret)#.unpack('a2'*32).map{|x| x.hex}.pack('c'*32)
    c.iv = iv = c.random_iv
    e = c.update(raw_pass)
    e << c.final
    return { :e => e, :key => key, :iv => iv }
  end

  # Decrypt a password 
  def self.decrypt_pass(encrypted_pass, key, iv)
    c = OpenSSL::Cipher::Cipher.new("aes-256-cbc")
    c.decrypt
    c.key = key
    c.iv = iv
    d = c.update(encrypted_pass)
    d << c.final
    return d
  end
end

class MyspacePictureDownloader < MyspaceMech
  
  attr_accessor :albums_page
  
  def get_all_images
    tolerated = [SocketError, Errno::ECONNRESET, Errno::EPIPE]
    titles = album_titles
    images = { }
    titles.each { |title|
      retry_count = 0
      begin
        images[title] = get_album_images(title)
      rescue *tolerated
        retry_count += 1
        retry if retry_count < 3
      end
    }
    return images
  end

  # Get the album index
  def find_albums_page
    @albums_page ||= @profile_owner_page.links.href(/user.editAlbums/).first.click
  end
  
  # Get all album titles
  def album_titles
    find_albums_page
    albums = @albums_page.search("[@class='album']")
    titles_h = albums.search("div[@class='photo_title']/a/").map{ |title| title.to_s }
  end

  
  # Scrape all images for the specified title
  def get_album_images(album_title)
    find_albums_page
    album_page = @albums_page.links.text(album_title).click
    sleep( rand(5) )
    get_images(album_page)
  end
  
  # Scrapes the image links on an individual album page
  def get_images(album_page)
    img_hrefs = album_page.search("a[@class='photo_image']").map { |link|
      sleep(rand(3))
      picture_page = @agent.get(link.attributes["href"])
      desired_picture = picture_page.search('img[@id*="serImage"]').first
      if desired_picture
        img_item = desired_picture.attributes["src"]
      else
        img_item = nil
      end
    }
    img_hrefs.compact
  end


end


class MyspacePictureUploader < MyspaceMech

  @basic_upload_page = nil   # Must be re-gotten after each upload

  # Upload one of more images to the specfied album.
  # image_file : array of strings, or single string containing filepath to upload
  # album_name : name of myspace album to upload to, main profile pictures if nil
  def upload(image_files, album_name = nil)
    image_files = [image_files] unless image_files.is_a? Array
    find_basic_upload_page
    image_file_report = { }
    image_files.each do |image_file|
      image_file_report[image_file] = upload_single_file(@basic_upload_page, image_file, album_name)
    end
    return image_file_report
  end

  #########
  protected
  #########

  # Initially (re)sets the basic_upload_page variable
  def find_basic_upload_page
    add_edit_photos_page = @profile_owner_page.links.href(/fuseaction=user.editAlbums/).click
    upload_page = add_edit_photos_page.links.text("Upload Photos").click

    basic_upload_link = nil
    upload_page = upload_page.links.href(/basicimageuploadform/).first.click
    @basic_upload_page = upload_page
  end

  # Uploads a single file using the basic image upload form
  # Returns true if successful, error message on failure
  def upload_single_file(upload_page, filename, album_name)
    upload_form = upload_page.forms.select{|f| f if f.file_uploads.size > 0}.first
    upload_form.file_uploads.first.file_name = filename
    if album_name
      upload_form = upload_form_set_album(upload_form, album_name)
    end

    upload_response = @agent.submit(upload_form, upload_form.buttons.first)
    @basic_upload_page = upload_response.links.href(/basicimageuploadform/).first.click
    return upload_single_file_check_success(upload_response)
  end

  def upload_form_set_album(upload_form, album_name)

    album_select_list = upload_form.fields.find_all{ |f| f.class ==  WWW::Mechanize::Form::SelectList }.first
    
    if album_select_list.nil? or album_select_list.options.size == 0
      return upload_form
    end

    if album_select_list.options.text(album_name).size > 0
      album_select_list.options.text(album_name).first.select
      upload_form.radiobuttons[0].checked=true
      upload_form.radiobuttons[1].checked=false
    else
      upload_form.fields.name(/NewAlbumName/).value = album_name
      upload_form.radiobuttons[1].checked=true
      upload_form.radiobuttons[0].checked=false
    end
    return upload_form
  end

  def upload_single_file_check_success(upload_response)
    response_text = upload_response.search('//[@id="ResultLabel"]').text
    if response_text.include? "There was an error"
      return response_text
    end
    return true
  end
end

