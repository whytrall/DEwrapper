module DEwrapper
  class HtmlParserIncluded < HTTParty::Parser
    def html
      Nokogiri::HTML(body)
    end
  end
end
