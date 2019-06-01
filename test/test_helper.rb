$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require 'DEwrapper'
require 'dotenv'
Dotenv.load('.env.test.local')

require 'minitest/autorun'
