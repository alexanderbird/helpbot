module Services
  class MessageService
    def initialize
      if Rails.application.config.use_real_twilio
        account_sid = Rails.application.credentials.twilio[:sid]
        auth_token = Rails.application.credentials.twilio[:token]
        @client = Twilio::REST::Client.new account_sid, auth_token
      else
        @client = MockTwilioClient.new
      end
    end

    def send_sms to_number, body
      @client.messages.create(
        from: Rails.application.credentials.twilio[:number],
        to: to_number,
        body: body
      )
    end
  end

  private
    class MockTwilioClient
      def messages
        MockTwilioClientMessages.new
      end
    end

    class MockTwilioClientMessages
      def create data
        Rails.logger.info "SMS from #{data[:from]} to #{data[:to]}: #{data[:body]}"
      end
    end
end
