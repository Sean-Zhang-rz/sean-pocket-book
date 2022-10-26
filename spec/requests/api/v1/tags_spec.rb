require 'rails_helper'

RSpec.describe "Api::V1::Tags", type: :request do
  describe "获取标签" do
    it "未登录获取标签" do
      get '/api/v1/tags'
      expect(response).to have_http_status(401)
    end
    it "登录获取标签" do
      user = User.create email: '770899447@qq.com'
      user1 = User.create email: '770899448@qq.com'
      11.times do |i| Tag.create name: "tag#{i}", user_id: user.id, sign: 'x' end
      11.times do |i| Tag.create name: "tag#{i}", user_id: user1.id, sign: 'x' end
      get '/api/v1/tags', headers: user.generate_auth_header
      expect(response).to have_http_status(200)
      json = JSON.parse response.body
      expect(json['data'].size).to eq 10

      get '/api/v1/tags', headers: user.generate_auth_header, params: {page: 2}
      expect(response).to have_http_status(200)
      json = JSON.parse response.body
      expect(json['data'].size).to eq 1
    end
  end
  describe "创建标签" do
    it '未登录创建标签' do
      post '/api/v1/tags', params: {name: 'x', sign: 'x'}
      expect(response).to have_http_status(401)
    end
    it '登录创建标签' do
      user = User.create email: '770899447@qq.com'
      post '/api/v1/tags', params: {name: 'x', sign: 'x'}, headers: user.generate_auth_header
      expect(response).to have_http_status(200)
      json = JSON.parse response.body
      expect(json['data']['name']).to eq 'x'
      expect(json['data']['sign']).to eq 'x'
    end
    it '登录创建失败，没填name' do
      user = User.create email: '770899447@qq.com'
      post '/api/v1/tags', params: { sign: 'x'}, headers: user.generate_auth_header
      expect(response).to have_http_status(422)
      json = JSON.parse response.body
      expect(json['errors']['name'][0]).to eq "can't be blank"
    end
    it '登录创建失败，没填sign' do
      user = User.create email: '770899447@qq.com'
      post '/api/v1/tags', params: { name: 'x'}, headers: user.generate_auth_header
      expect(response).to have_http_status(422)
      json = JSON.parse response.body
      expect(json['errors']['sign'][0]).to eq "can't be blank"
    end
  end
  describe "更新标签" do
    it '未登录修改标签' do
      user = User.create email: '770899447@qq.com'
      tag = Tag.create name: 'x', sign: 'x', user_id: user.id
      patch "/api/v1/tags/#{tag.id}", params: {name: 'y', sign: 'y'}
      expect(response).to have_http_status(401)
    end
    it '登录修改标签' do
      user = User.create email: '770899447@qq.com'
      tag = Tag.create name: 'x', sign: 'x', user_id: user.id
      patch "/api/v1/tags/#{tag.id}", params: {name: 'y', sign: 'y'}, headers: user.generate_auth_header
      expect(response).to have_http_status(200)
      json = JSON.parse response.body
      expect(json['data']['name']).to eq 'y'
      expect(json['data']['sign']).to eq 'y'
    end
    it '登录部分修改，没填name' do
      user = User.create email: '770899447@qq.com'
      tag = Tag.create name: 'x', sign: 'x', user_id: user.id
      patch "/api/v1/tags/#{tag.id}", params: { sign: 'y'}, headers: user.generate_auth_header
      expect(response).to have_http_status(200)
      json = JSON.parse response.body
      expect(json['data']['name']).to eq 'x'
      expect(json['data']['sign']).to eq 'y'
    end
    it '登录部分修改，没填sign' do
      user = User.create email: '770899447@qq.com'
      tag = Tag.create name: 'x', sign: 'x', user_id: user.id
      patch "/api/v1/tags/#{tag.id}", params: { name: 'y'}, headers: user.generate_auth_header
      expect(response).to have_http_status(200)
      json = JSON.parse response.body
      expect(json['data']['name']).to eq 'y'
      expect(json['data']['sign']).to eq 'x'
    end
  end
end
