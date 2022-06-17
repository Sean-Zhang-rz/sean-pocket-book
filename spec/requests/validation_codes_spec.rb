require 'rails_helper'

RSpec.describe "ValidationCodes", type: :request do
  describe "发送验证码" do
    it "发送太频繁了" do
      post '/api/v1/validation_codes', params: {email: '770899447@qq.com'}
      expect(response).to have_http_status(200)
      post '/api/v1/validation_codes', params: {email: '770899447@qq.com'}
      expect(response).to have_http_status(429)
    end
  end
end
