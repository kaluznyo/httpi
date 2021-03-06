module HTTPI

  # = HTTPI::Cookie
  #
  # Represents a single delicious cookie.
  #
  # == Examples
  #
  #   cookie = HTTPI::Cookie.new("token=choc-choc-chip; Path=/; HttpOnly")
  #
  #   cookie.name            # "token"
  #   cookie.name_and_value  # "token=choc-choc-chip"
  class Cookie

    # Returns a list of cookies from a Hash of +headers+.
    def self.list_from_headers(headers)
      p "Cookie::list_from_headers"
      Array(headers["Set-Cookie"]).map { |cookie| new(cookie) }
    end

    def initialize(cookie)
      p "Cookie::initialize"
      
      @cookie = cookie
    end

    # Returns the name of the cookie.
    def name
      p "Cookie::name"
      
      @cookie.split("=").first
    end

    # Returns the name and value of the cookie.
    def name_and_value
      p "Cookie::name_and_value"
      
      @cookie.split(";").first
    end

  end
end
