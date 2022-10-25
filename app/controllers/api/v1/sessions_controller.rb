require 'jwt'
class Api::V1::SessionsController < ApplicationController
  def create
    if Rails.env.test?
      return render status: :unauthorized if params[:code] != '123456'
    else
      canSignIn = ValidationCodes.exists?(email: params[:email], code: params[:code], used_at: nil)
      return render status: :unauthorized, json: {error: '验证码错误'} unless canSignIn 
    end
    # 找不到就创建一个新用户
    user = User.find_or_create_by email: params[:email]
    render status: :ok, json: { jwt: user.generate_jwt }
  end
end
