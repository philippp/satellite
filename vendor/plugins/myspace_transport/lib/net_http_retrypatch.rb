# Monkeypatch Net::HTTP to retry 3 times if our connection gets killed. 
# Each time we reconnect after a random 0-10 second delay.
module Net   #:nodoc:

  class HTTP < Protocol
    # Sends an HTTPRequest object REQUEST to the HTTP server.
    # This method also sends DATA string if REQUEST is a post/put request.
    # Giving DATA for get/head request causes ArgumentError.
    #
    # When called with a block, yields an HTTPResponse object.
    # The body of this response will not have been read yet;
    # the caller can process it using HTTPResponse#read_body,
    # if desired.
    #
    # Returns a HTTPResponse object.
    #
    # This method never raises Net::* exceptions.
    #
    def request(req, body = nil, &block)  # :yield: +response+
      unless started?
        start {
          req['connection'] ||= 'close'
          return request(req, body, &block)
        }
      end
      if proxy_user()
        unless use_ssl?
          req.proxy_basic_auth proxy_user(), proxy_pass()
        end
      end
      @http_retries = 3
      begin
        req.set_body_internal body
        begin_transport req
        req.exec @socket, @curr_http_version, edit_path(req.path)
        begin
          res = HTTPResponse.read_new(@socket)
        end while res.kind_of?(HTTPContinue)
        res.reading_body(@socket, req.response_body_permitted?) {
          yield res if block_given?
        }
        end_transport req, res

        res
      rescue Timeout::Error
        if @http_retries > 0
          @http_retries -= 1
          retry
        end
      rescue
        if @http_retries > 0
          @http_retries -= 1
          @socket.close
          sleep(10)
          @socket.start
          retry
        end
      end
      res
    end
  end #class HTTP
end #module NET
