require "uri"
require "httpi/cookie_store"
require "httpi/auth/config"
require "rack/utils"

module HTTPI

  # = HTTPI::Request
  #
  # Represents an HTTP request and contains various methods for customizing that request.
  class Request

    # Available attribute writers.
    ATTRIBUTES = [:url, :proxy, :headers, :body, :open_timeout, :read_timeout]

    # Accepts a Hash of +args+ to mass assign attributes and authentication credentials.
    def initialize(args = {})
      p "Request::initialize"
      if args.kind_of? String
        self.url = args
      elsif args.kind_of?(Hash) && !args.empty?
        mass_assign args
      end
    end

    # Sets the +url+ to access. Raises an +ArgumentError+ unless the +url+ is valid.
    def url=(url)
      p "Request::url="
      
      @url = normalize_url! url
      auth.basic @url.user, @url.password || '' if @url.user
    end

    # Returns the +url+ to access.
    attr_reader :url

    # Sets the +query+ from +url+. Raises an +ArgumentError+ unless the +url+ is valid.
    def query=(query)
      p "Request::query="
      
      raise ArgumentError, "Invalid URL: #{self.url}" unless self.url.respond_to?(:query)
      if query.kind_of?(Hash)
        query = Rack::Utils.build_query(query)
      end
      query = query.to_s unless query.is_a?(String)
      self.url.query = query
    end

    # Returns the +query+ from +url+.
    def query
      p "Request::query"
      
      self.url.query if self.url.respond_to?(:query)
    end

    # Sets the +proxy+ to use. Raises an +ArgumentError+ unless the +proxy+ is valid.
    def proxy=(proxy)
      p "Request::proxy="
      
      @proxy = normalize_url! proxy
    end

    # Returns the +proxy+ to use.
    attr_reader :proxy

    # Returns whether to use SSL.
    def ssl?
      p "Request::ssl?"
      
      return @ssl unless @ssl.nil?
      !!(url.to_s =~ /^https/)
    end

    # Sets whether to use SSL.
    attr_writer :ssl

    # Returns a Hash of HTTP headers. Defaults to return an empty Hash.
    def headers
      p "Request::headers"
      
      @headers ||= Rack::Utils::HeaderHash.new
    end

    # Sets the Hash of HTTP headers.
    def headers=(headers)0
      p "Request::headers"
      
      @headers = Rack::Utils::HeaderHash.new(headers)
    end

    # Adds a header information to accept gzipped content.
    def gzip
      p "Request::gzip"
      
      headers["Accept-Encoding"] = "gzip,deflate"
    end

    # Sets the cookies from an object responding to `cookies` (e.g. `HTTPI::Response`)
    # or an Array of `HTTPI::Cookie` objects.
    def set_cookies(object_or_array)
      p "Request::set_cookies"
      
      if object_or_array.respond_to?(:cookies)
        cookie_store.add *object_or_array.cookies
      else
        cookie_store.add *object_or_array
      end

      cookies = cookie_store.fetch
      headers["Cookie"] = cookies if cookies
    end

    attr_accessor :open_timeout, :read_timeout
    attr_reader :body

    # Sets a body request given a String or a Hash.
    def body=(params)
      p "Request::body="
      
      @body = params.kind_of?(Hash) ? Rack::Utils.build_query(params) : params
    end

    # Sets the block to be called while processing the response. The block
    # accepts a single parameter - the chunked response body.
    def on_body(&block)
      p "Request::on_body"
      
      if block_given? then
        @on_body = block
      end
      @on_body
    end

    # Returns the <tt>HTTPI::Authentication</tt> object.
    def auth
      p "Request::auth"
      
      @auth ||= Auth::Config.new
    end

    # Returns whether any authentication credentials were specified.
    def auth?
      p "Request::auth?"
      
      !!auth.type
    end

    # Expects a Hash of +args+ to assign.
    def mass_assign(args)
      p "Request::mass_assign"
      
      ATTRIBUTES.each { |key| send("#{key}=", args[key]) if args[key] }
    end

    private

    # Stores the cookies from past requests.
    def cookie_store
      p "Request::cookie_store"
      
      @cookie_store ||= CookieStore.new
    end

    # Expects a +url+, validates its validity and returns a +URI+ object.
    def normalize_url!(url)
      p "Request::normalize_url"
      
      raise ArgumentError, "Invalid URL: #{url}" unless url.to_s =~ /^http/
      url.kind_of?(URI) ? url : URI(url)
    end

  end
end
