require 'httparty'
require 'nokogiri'
require 'ext/cookie_monster'
require 'time'

require 'DEwrapper/version'
require 'DEwrapper/html_parser'
require 'DEwrapper/marks'
require 'DEwrapper/user'

module DEwrapper
  class Error < StandardError; end
  class GeneralLoginError < Error; end
  class InvalidLoginOrPasswordError < GeneralLoginError; end
  class NoTokenError < GeneralLoginError; end

  DE_HOST = 'de.ifmo.ru'.freeze # de.spmu.runnet.ru also works

  USERAGENT = "trallDEWrapper/#{VERSION}".freeze
  DEFAULT_HEADERS = {
      'Cookie' => "",
      'User-Agent' => ::DEwrapper::USERAGENT
  }# .freeze
end

