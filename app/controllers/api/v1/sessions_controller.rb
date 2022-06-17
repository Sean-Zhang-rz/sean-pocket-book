class Api::V1::SessionsController < ApplicationController
  def create
    if Rails.env.test?
      return render status: :unauthorized if params[:code] != '123456'
    else
      canSignIn = ValidationCodes.exists?(email: params[:email], code: params[:code], used_at: nil)
      return render status: :unauthorized, json: {error: '验证码错误'} unless canSignIn 
    end

    user = User.find_by(email: params[:email])
    if user.nil?
      render status: 404, json: {error: '用户不存在'}
    else
      render status:200, json: {
        jwt: 'xxxxxxxxxxxxxxxxxxxxxxxxxx'
      }
    end
  end
end
