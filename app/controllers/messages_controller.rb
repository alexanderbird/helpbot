class MessagesController < ApplicationController 
  before_action :check_api_key
  before_action :connect_to_twilio

  def reply
    message_body = params["Body"]
    from_number = params["From"]
    connect_to_twilio
    @message_service.send_sms from_number, "Hello there, thanks for texting me. Your number is #{from_number}."
  end

  private
    def connect_to_twilio
      @message_service = Services::MessageService.new
    end
end
