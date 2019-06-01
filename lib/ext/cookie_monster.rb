# https://github.com/hirschnase/CookieMonster/blob/master/lib/cookie_monster.rb

class CookieMonster

  attr_accessor :name
  attr_accessor :value
  attr_accessor :domain
  attr_accessor :path
  attr_accessor :expires
  attr_accessor :httponly
  attr_accessor :secure

  # init - a raw cookie can be passed for parsing. a hash with attributes can be handed in as well.
  #
  def initialize(args=nil)
    from_header(args) if args.is_a? String
    if args.is_a? Hash
      args.each do |k,v|
        _set([k,v])
      end
    end
    self
  end

  # helper method to mass asign attributes
  #
  def _set(kv)
    case kv.first.to_sym
    when :name
      @name = kv.last
    when :value
      @value = kv.last
    when :path
      @path = kv.last
    when :domain
      @domain = kv.last
    when :expires
      @expires = Time.parse(kv.last.gsub('GMT', 'UTC'))
    when :httponly
      @httponly = true
    when :secure
      @secure = true
    end
  end

  # parse a cookie header string
  #
  def from_header(header)
    parse(header.gsub(/^set-cookie:\s*/i, '').gsub(/^cookie:\s*/i, ''))
  end

  # parse a raw cookie string
  #
  def parse(raw_cookie)
    cookie = raw_cookie.split(/\;\s*/)

    kv = cookie.shift
    @name   = URI.unescape(kv.split('=').first)
    @value  = URI.unescape(kv.split('=').last)

    cookie.each do |kv|
      _set(kv.split('='))
    end

  end

  # convert the cookie to a string
  #
  def to_s
    validate!
    URI.escape(name.to_s) + '=' + (value ? URI.escape(value.to_s) : '') +
        (domain   ? '; domain='+domain        : '') +
        (path     ? '; path='+path            : '') +
        (expires  ? '; expires='+expires.to_time.utc.strftime('%a, %d-%b-%Y %T GMT') : '') +
        (httponly ? '; httponly'              : '') +
        (secure   ? '; secure'                : '')
  end

  # convert the cookie to a HTTP response header
  #
  def to_header
    validate!
    "Set-Cookie: " + to_s
  end

  # sets the cookie expiry in seconds from now
  #
  def expires_in_seconds(secs)
    @expires = Time.now.utc + secs;
    self
  end

  # expires the cookie by settings its expire date to 7 days ago - browsers will then delete the cookie from their jar
  #
  def expire!
    @expires = Time.now.utc - 7*86400;
    self
  end

  # deletes the cookie by removing it's value - browsers will then delete the cookie from their jar
  #
  def delete!
    @value = ''
    self
  end

  # runs some simple validation against the cookie - throws exceptions!
  #
  def validate!
    raise 'Cookie name must be defined' unless name
    raise 'Cookie expires is not an instance of the Time class' if expires and ! expires.is_a? Time
  end

  # validates the cookie - returns true or false
  #
  def is_valid?
    begin
      validate!
      true
    rescue => ex
      false
    end
  end

end
