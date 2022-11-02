require 'rails_helper'
require 'active_support/testing/time_helpers'

RSpec.describe "Me", type: :request do
  include ActiveSupport::Testing::TimeHelpers
  describe "获取当前用户" do
    it "登录后成功获取" do
      user = create :user 
      post '/api/v1/session', params: {email: user.email, code: '123456'}
      json = JSON.parse response.body
      jwt = json['data']['jwt']

      get '/api/v1/me', headers: {'Authorization': "Bearer #{jwt}"}
      expect(response).to have_http_status(200)
      json = JSON.parse response.body
      expect(json['data']['id']).to eq user.id
    end
    it "jwt 过期" do
      travel_to Time.now - 3.hours
      user1 = create :user 
      jwt = user1.generate_jwt

      travel_back
      get '/api/v1/me', headers: {'Authorization': "Bearer #{jwt}"}
      expect(response).to have_http_status(401)
    end
    it "jwt 没过期" do
      travel_to Time.now - 1.hours
      user1 = create :user 
      jwt = user1.generate_jwt

      travel_back
      get '/api/v1/me', headers: {'Authorization': "Bearer #{jwt}"}
      expect(response).to have_http_status(200)
    end
  end
end 