class MessagesController < ApplicationController 
  before_action :check_api_key
  before_action :initialize_message_service
  before_action :sign_in_user

  def reply
    return unless @user
    return if @first_login
    from_number = params[:From]
    body = params[:Body]
    if body == 'logout'
      @user.destroy! 
      sms "👋 Successfully logged out."
    else
      sms Toolbox::Toolbox.new.handle body
    end
  end

  private
    def sms message
      from_number = params[:From]
      @message_service.send_sms from_number, message
    end

    def initialize_message_service
      @message_service = Services::MessageService.new
    end

    def sign_in_user
      from_number = params[:From]
      @user = User.find_by_phone from_number
      if !@user
        body = params[:Body]
        if body == Rails.application.credentials.authentication[:sms]
          @user = User.create! phone: from_number
          sms "👋 Welcome!"
          @first_login = true
        else
          sms "You are not authorized to use this service."
        end
      end
    end
end
