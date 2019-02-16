module Toolbox
  module Tools
    class Dictionary < Base
      def self.will_handle
        /define .*/
      end
      def self.help_text
        "define <word>"
      end
      def handle
        word = @input.match(/define (.*)/)[1]
        DictionaryEntry.get(word).to_s
      rescue DictionaryApiNotOKError => e
        "There was a problem connecting to the dictionary api"
      end

      private
      class DictionaryEntry
        def self.get word
          response = OxfordDictionaryApi.define word
          if response.success?
            new response.data[:results][0][:lexicalEntries]
          else
            DictionaryInflection.get(word) || DictionaryMisspellings.get(word)
          end
        end

        def initialize lexicalEntries
          @data = []
          lexicalEntries.each do |lexicalEntry|
            @data << {
              category: lexicalEntry[:lexicalCategory].upcase,
              entries: lexicalEntry[:entries].map do |entry|
                entry[:senses].map do |sense|
                  domains = sense[:domains]
                  definition = sense[:definitions][0]
                  if domains
                    definition = "#{domains.join(", ")}: #{definition}"
                  else
                    definition[0] = definition[0].capitalize
                  end
                   definition
                end
              end
            }
          end
        end

        def to_s
          @data.map do |group|
            outer_prefix = @data.length > 1 ? "1. " : ""
            group_text = group[:entries].map do |entry|
              entry_text = ""
              if entry.length > 1
                inner_prefix = "a) "
                entry_text = entry.map do |sense|
                  sense_text = "#{outer_prefix}#{inner_prefix}#{sense}"
                  inner_prefix = inner_prefix.next
                  sense_text
                end.join "\n\n"
              else
                entry_text = "#{outer_prefix}#{entry.first}"
              end
              outer_prefix = outer_prefix.next
              entry_text
            end.join "\n\n"
            group[:category] + "\n" + group_text
          end.join "\n\n"
        end
      end

      class DictionaryInflection
        def self.get word
          response = OxfordDictionaryApi.inflections word
          return nil unless response.success?
          new response.data[:results][0][:lexicalEntries]
        end

        def initialize lexicalEntries
          @inflections = lexicalEntries.map do |lexicalEntry|
            lexicalEntry[:inflectionOf][0][:text]
          end
        end

        def to_s
          "Did you mean\n" + @inflections.map do |inflection|
            " - #{inflection}"
          end.join("\n")
        end
      end

      class DictionaryApiNotOKError < StandardError
      end

      class DictionaryMisspellings
        def self.get word
          response = OxfordDictionaryApi.misspellings word
          raise DictionaryApiNotOKError.new unless response.success?
          new response.data[:results]
        end

        def initialize results
          @alternatives = results.map do |result|
            result[:word]
          end
        end

        def to_s
          return "🤦 Wow, that's not even close to a real word." unless @alternatives.any?
          "Did you mean\n" + @alternatives.map do |alternative|
            " - #{alternative}"
          end.join("\n")
        end
      end

      class OxfordDictionaryApi
        def self.define word
          get "/v1/entries/en/#{word}"
        end

        def self.inflections word
          get "/v1/inflections/en/#{word}"
        end

        def self.misspellings word
          get "/v1/search/en?q=#{word}&prefix=false"
        end

        private
        def self.get url
          request = Typhoeus::Request.new(
            "https://od-api.oxforddictionaries.com:443/api#{url}",
            headers: {
              "app_key" => Rails.application.credentials.integrations[:dictionary_key],
              "app_id" => Rails.application.credentials.integrations[:dictionary_id]
            }
          )
          request.run
          ApiResult.new request.response
        end
      end

      class ApiResult
        attr_reader :data

        def initialize response
          @success = response.success?
          @success && @data = JSON.parse(response.response_body).with_indifferent_access
        end

        def success?
          @success
        end
      end
    end
  end
end
