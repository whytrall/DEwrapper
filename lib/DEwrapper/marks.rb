module DEwrapper
  class Marks
    include HTTParty
    base_uri 'de.ifmo.ru'
    parser HtmlParserIncluded
    debug_output

    def initialize(user)
      @options = { headers: DEFAULT_HEADERS }
      @options[:headers]["Cookie"] = "JSESSIONID=#{user.token}; User_lang_id=1;"
    end

    def current(semester)
      # TODO: Break down into separate class

      req = self.class.get('/servlet/distributedCDE?Rule=eRegister', @options)

      sem_flag = false
      full_data = req.css('#FormName .d_table tr').drop(1)

      schema = { semesters: {} }

      curr_sem = -1

      full_data.each do |row| #
        try_header_el = row.at_css('th[colspan="9"]')
        unless try_header_el.nil?
          curr_sem = try_header_el.text.scan(/\d/)[0].to_i
          if (curr_sem == semester && !sem_flag) || semester.zero?
            schema[:semesters][curr_sem] = []
            sem_flag = true
          elsif !sem_flag
            next
          elsif semester != 0
            break
          end
        end

        next unless sem_flag

        t = parse_row(row)

        schema[:semesters][curr_sem.to_i].push t unless t[:subject].empty?
      end

      schema
    end

    private
    def parse_row row
      all_exams = %i[exam credit diff_credit course_work course_project]
      exam_type = :unknown
      exam_result = nil

      all_exams.each_with_index do |ex, idx|
        # yes, this looks like shit
        # but nokogiri doesn't work as it supposed to
        next if Nokogiri::HTML(row.css('td')[idx+4].to_s).css('*').text == ''

        exam_type = ex
        unless row.css('td')[idx + 4].text == 'x'
          exam_result = row.css('td')[idx + 4].text
        end
      end
      {
        subject: row.css('a').text,
        rating: Nokogiri::HTML(row.css('td')[3].to_s).css('td').text.sub(',', '.').to_f,
        examination_type: exam_type,
        examination_result: exam_result
      }
    end
  end
end