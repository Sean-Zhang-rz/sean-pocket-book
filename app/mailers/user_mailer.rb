class UserMailer < ApplicationMailer
  def welcome_email(email)
    validation_code = ValidationCode.find_by_email(email)
    @code = validation_code
    # @user = params[:user]
    # @url  = 'http://example.com/login'
    mail(to:email, subject: '山竹记账验证码')
  end
end
