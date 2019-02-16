module Toolbox
  module Tools
    class Bible < Base
      def self.will_handle
        /^bible(?:| .+ .+)$/
      end
      def self.help_text
        "bible [<book> <chapter and verse>]"
      end
      def handle
        passage_reference = @input.match(/bible(?: (.*)|)/)[1]
        passage_reference ||= "Proverbs #{Time.zone.today.day}:1-5"
        passage = BiblePassage.get passage_reference
        passage.to_s
      rescue BiblePassageNotFoundError => e
        "Nothing found for \"#{passage_reference}\""
      rescue BibleApiNotOKError => e
        "There was a problem connecting to the Bible api"
      end
    end

    private
      VERSE_LIMIT = 5
      class BiblePassage
        def self.get reference
          request = Typhoeus::Request.new(
            "https://api.scripture.api.bible/v1/bibles/de4e12af7f28f599-01/search?query=#{reference.gsub(/ /, '%20')}",
            headers: { "api-key" => Rails.application.credentials.integrations[:bible] }
          )
          request.run
          raise BibleApiNotOKError unless request.response.success?
          json = request.response.response_body
          data = JSON.parse(json).with_indifferent_access
          raise BiblePassageNotFoundError unless data[:data][:passages]
          passage = data[:data][:passages][0]
          content_html = Nokogiri::HTML(passage[:content])
          verse_number_nodes = content_html.css("span[data-number]")
          verse_count = verse_number_nodes.length
          verse_number_nodes.each_with_index do |verse_number, i|
            if i < VERSE_LIMIT
              br = content_html.create_element "br"
              verse_number.replace br
            elsif i == VERSE_LIMIT
              end_marker = content_html.create_text_node "----END----"
              verse_number.replace end_marker
            end
          end
          content_html.css("span:not([data-number])").each do |other_span|
            text = content_html.create_text_node other_span.text
            other_span.replace text
          end
          content = content_html.css('p').children
            .map{ |c| c.text.gsub(/¶/, '') }
            .reject(&:empty?)
            .map(&:strip)
            .join("\n\n")
            .sub(/----END----.*$/, '')
            .strip

          return new content, passage[:reference], verse_count
        end
        def initialize text, reference, verse_count
          @text = text 
          @reference = reference
          @verse_count = verse_count
        end

        def to_s
          notice_part = notices ? " #{notices}" : ""
          "#{@text}\n — #{@reference}#{notice_part}"
        end

        private
          def notices
            if @verse_count > VERSE_LIMIT
              "(#{VERSE_LIMIT}/#{@verse_count} verses shown)"
            end
          end
      end
      class BiblePassageNotFoundError < StandardError
      end
      class BibleApiNotOKError < StandardError
      end
  end
end
