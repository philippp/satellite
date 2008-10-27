class SmugmugTransport
    
  @@SmugMugURL = {
    :get => {
      :host => "api.smugmug.com",
      :root => "/hack/rest/"
    },
    :post => {
      :host => "upload.smugmug.com",
      :root => "/hack/rest/"
    }
  }
    
  @session_id = nil
  
  # Log in with unencrypted username and password. 
  # This should only be done once, unless the password changes. 
  # The authentication ID and hashed password are returned and 
  # should be stored locally and used with smugmug_login_hash 
  # for further requests. 
  def login_raw(email, password)
    
      parameters = {
      "EmailAddress" => email,
      "Password" => password
    }

    resp = api_call( "smugmug.login.withPassword", parameters ) 
    
    if resp["stat"] == "ok" && resp["SessionID"]
      @session_id = resp["SessionID"]
      return { :user_id => resp["UserID"], :pw_hash => resp["PasswordHash"], :session_id => resp["SessionID"]}
    else
      raise "Failed to authenticate: #{resp.inspect}"
    end
  end
 

  # Log in with hashed password and smugmug ID. Provides a session 
  # id for further calls. 
  def login_hash( user_id, pw_hash )
    parameters = {
      "UserID" => user_id,
      "PasswordHash" => pw_hash
    }
    resp = api_call( "smugmug.login.withHash", parameters )
    if resp["stat"] == "ok" && resp["SessionID"]
      #TODO: The session times out after 6 hours of inactivity, but $smugmug_sessions
      #is persistent. Suggestion: store and check time in $smugmug_sessions
      @session_id = resp["SessionID"]
      return { :session_id => resp["SessionID"] }
    else
      raise "Failed to authenticate: #{resp.inspect}" 
    end
  end
  
  # Makes a call to smugmug and returns a response hash. 
  # Specify the session_id to authenticate requests once a session is active.
  #
  # @throws Exception message and error code are thrown on failure
  def api_call( sm_method, sm_arguments = { } )
    http_client = Net::HTTP.new(@@SmugMugURL[:get][:host], 443)
    http_client.use_ssl = true
    http2 = http_client.start

    url_base = @@SmugMugURL[:get][:root] + "?"
    if @session_id.nil?
      smugmug_url = url_base + "APIKey="+URI.escape(SMUGMUG_API_KEY)+"&"
    else
      smugmug_url = url_base + "SessionID="+URI.escape(@session_id)+"&"
    end

    sm_arguments.each do |key, val|
      smugmug_url = smugmug_url + key + "=" + URI.escape(val.to_s) + "&"
    end

    smugmug_url = smugmug_url + "method="+URI.escape(sm_method)
    request = Net::HTTP::Get.new(smugmug_url)
    response = http2.request(request)
    if response.code == "200"
      return Hash.from_xml( response.body ).values.first;
    else
      raise "Failed with HTTP Response: #{response.inspect}"
    end
  end
  
end


