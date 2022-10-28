class Api::V1::ValidationCodesController < ApplicationController
  def create
    # ValidationCode.where(email: params[:email], kind: 'sign_in',created_at: 1.minute.ago..Time.now).find_by_email
    if ValidationCode.exists?(email: params[:email], kind: 'sign_in',created_at: 1.minute.ago..Time.now)
      render status: :too_many_requests, json: {error: '验证码已发送，请稍后再试'}
      return
    end
    validation_code = ValidationCode.new email: params[:email], kind: 'sign_in'
    if validation_code.save
      render json: {data: validation_code.code, msg: 'ok'}, status:200
    else
      errors = validation_code.errors.messages[:email][0]
      render json: {msg: errors}, status:422
    end
  end
end
