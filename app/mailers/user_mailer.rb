class UserMailer < ApplicationMailer
  def welcome_email(code)
    @code = code
    # @user = params[:user]
    # @url  = 'http://example.com/login'
    mail(to:"srz964@163.com", subject: 'Welcome to My Awesome Site, hi')
  end
end
