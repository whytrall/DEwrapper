# frozen_string_literal: true

require './test/test_helper'

class DEwrapperTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::DEwrapper::VERSION
  end

  def skip_test_user_auth
    d = DEwrapper::User.new_with_login(ENV['DE_LOGIN'], ENV['DE_PASSWORD'])
  end

  def skip_test_user_info
    d = DEwrapper::User.new_with_login(ENV['DE_LOGIN'], ENV['DE_PASSWORD'])
    puts d.info
  end

  def test_marks
    d = DEwrapper::User.new_with_login(ENV['DE_LOGIN'], ENV['DE_PASSWORD'])
    pp d.marks.current(0)
  end
end
