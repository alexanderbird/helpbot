class ApplicationController < ActionController::API
  private
    def check_api_key
      if params[:key] != Rails.application.credentials.authentication[:api]
        render :nothing => true, :status => :unauthorized
      end
    end
end
