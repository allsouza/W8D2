require 'json'

class Session
  # find the cookie for this app
  # deserialize the cookie into a hash
  def initialize(req)
    cookie = req.cookies["_rails_lite_app"]
    @clean_cookie = cookie ? JSON.parse(cookie) : {}

  end

  def [](key)
    @clean_cookie[key]
  end

  def []=(key, val)
    @clean_cookie[key] = val
  end

  # serialize the hash into json and save in a cookie
  # add to the responses cookies
  def store_session(res)
    res.set_cookie('_rails_lite_app', {path: "/", value: @clean_cookie.to_json})
  end
end