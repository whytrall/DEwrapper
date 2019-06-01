# frozen_string_literal: true

module DEwrapper
  class User
    attr_accessor :token

    include HTTParty
    base_uri 'de.ifmo.ru'
    parser HtmlParserIncluded
    # debug_output

    # @param [String] token (read more at README.md), [Int] user_id?
    # @return ¯\_(ツ)_/¯
    def initialize(token, user_id = nil)
      @token = token
      @user_id = user_id
      @user_info = nil
      @options = { headers: DEFAULT_HEADERS }
      @options[:headers]['Cookie'] = "JSESSIONID=#{@token}; User_lang_id=1;"
    end

    # @param [String] login, [String] password
    # @return User.new
    def self.new_with_login(login, password)
      req = post('/servlet', headers: DEFAULT_HEADERS, body: {
                   'Rule': 'LOGON',
                   'LOGIN': login.to_s,
                   'PASSWD': password.to_s
                 })

      if req.to_s.include?('Invalid login/password')
        raise InvalidLoginOrPasswordError
      end

      raise GeneralLoginError unless req.to_s.include?('SECURITYGROUP')

      # This big thing extracts token from cookie
      isu_id = req.css('input[name="PERSON"]').first['value']
      token = req.headers['set-cookie'][/JSESSIONID=(.*?).academicnt/m, 1]
      token_idx_start = req.headers['set-cookie'].index('academicnt') + 10
      token_number = req.headers['set-cookie'][token_idx_start]
      token = "#{token}.academicnt#{token_number}"

      if token.nil?
        puts req.headers['set-cookie']
        raise NoTokenError
      end

      new(token, isu_id)
    end

    # @return Hash
    def info
      @user_info unless @user_info.nil?

      req = self.class.get('/servlet/distributedCDE?Rule=editPersonProfile',
                           @options)

      els = req.css('form[name="editForm"] .d_table tr')

      @user_info = {
        id: @user_id,
        first_name: els[1].css('td[colspan]').text,
        middle_name: els[2].css('td[colspan]').text,
        last_name: els[0].css('td[colspan]').text,

        is_male: els[3].css('td[colspan]').text.strip == 'М',

        dob: Time.parse(els[4].css('td[colspan]').text),
        pob: els[5].css('td[colspan]').text
      }
    end

    # @return Marks.new
    def marks
      DEwrapper::Marks.new(self)
    end
  end
end
