class MessagesController < ApplicationController 
  before_action :check_api_key
  before_action :connect_to_twilio

  def reply
    message_body = params["Body"]
    from_number = params["From"]
    connect_to_twilio
    sms = @client.messages.create(
      from: Rails.application.credentials.twilio[:number],
      to: from_number,
      body: "Hello there, thanks for texting me. Your number is #{from_number}."
    )
  end

  private
    def connect_to_twilio
      account_sid = Rails.application.credentials.twilio[:sid]
      auth_token = Rails.application.credentials.twilio[:token]
      @client = Twilio::REST::Client.new account_sid, auth_token
    end
end
