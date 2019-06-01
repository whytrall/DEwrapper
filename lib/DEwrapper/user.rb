# frozen_string_literal: true

module DEwrapper
  class User
    attr_accessor :token

    include HTTParty
    base_uri 'de.ifmo.ru'
    parser HtmlParserIncluded
    # debug_output

    def initialize(token, user_id = nil)
      @token = token
      @user_id = user_id
      @options = { headers: DEFAULT_HEADERS }
      @options[:headers]["Cookie"] = "JSESSIONID=#{@token}; User_lang_id=1;"
    end

    def self.new_with_login(login, password)
      req = post('/servlet', headers: DEFAULT_HEADERS, body: {
          'Rule': 'LOGON',
          'LOGIN': login.to_s,
          'PASSWD': password.to_s
      })

      raise InvalidLoginOrPasswordError if req.to_s.include?('Invalid login/password')
      raise GeneralLoginError unless req.to_s.include?('SECURITYGROUP')

      isu_id = req.css('input[name="PERSON"]').first['value']
      token = req.headers['set-cookie'][/JSESSIONID=(.*?).academicnt/m, 1]
      token_number = req.headers['set-cookie'][req.headers['set-cookie'].index("academicnt")+10]

      if token.nil?
        puts req.headers['set-cookie']
        raise NoTokenError
      end

      new("#{token}.academicnt#{token_number}", isu_id)
    end

    def info
      req = self.class.get('/servlet/distributedCDE?Rule=editPersonProfile', @options)

      els = req.css('form[name="editForm"] .d_table tr')
      {
          first_name: els[1].css('td[colspan]').text,
          middle_name: els[2].css('td[colspan]').text,
          last_name: els[0].css('td[colspan]').text,
          is_male: els[3].css('td[colspan]').text.strip == 'М',
          dob: Time.parse(els[4].css('td[colspan]').text),
          pob: els[5].css('td[colspan]').text
      }
    end

    def marks
      ::DEwrapper::Marks.new(self)
    end
  end
end
