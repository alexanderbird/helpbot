Rails.application.routes.draw do
  post 'sms/:key', to: 'messages#reply'
end
