require 'rails_helper'

RSpec.describe "ValidationCodes", type: :request do
  describe "发送验证码" do
    it "发送太频繁了" do
      post '/api/v1/validation_codes', params: {email: '770899447@qq.com'}
      expect(response).to have_http_status(200)
      post '/api/v1/validation_codes', params: {email: '770899447@qq.com'}
      expect(response).to have_http_status(429)
    end
    it "邮件不合法就返回422" do
      post '/api/v1/validation_codes', params: {email: '770899447'}
      expect(response).to have_http_status(422)
      json = JSON.parse response.body
      expect(json['msg']).to eq('邮箱地址格式不正确')
    end
  end
end
