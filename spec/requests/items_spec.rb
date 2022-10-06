require 'rails_helper'

RSpec.describe "Items", type: :request do
  describe "账目获取" do
    it "分页" do
      user1 = User.create email: '1@qq.com'
      user2 = User.create email: '2@qq.com'
      11.times {Item.create amount: 100, user_id: user1.id}
      11.times {Item.create amount: 100, user_id: user2.id}
      expect(Item.count).to eq(22)
      post '/api/v1/session', params: {email: user1.email, code: '123456'}
      json = JSON.parse response.body
      jwt = json['jwt']

      get '/api/v1/items', headers: {'Authorization': "Bearer #{jwt}"} 
      expect(response).to have_http_status(200)
      json = JSON.parse(response.body)
      expect(json['data']['items'].size).to eq(10)
      get '/api/v1/items?page=2', headers: {'Authorization': "Bearer #{jwt}"}
      json = JSON.parse(response.body)
      expect(json['data']['items'].size).to eq(1)
    end

    it "按时间筛选" do
      item1 = Item.create amount: 100, created_at: Time.new(2018, 1, 2)
      item2 = Item.create amount: 100, created_at: Time.new(2018, 1, 2)
      item3 = Item.create amount: 200, created_at: Time.new(2019, 1, 1)
      get '/api/v1/items?created_after=2018-01-01&created_brefore=2018-01-02'
      expect(response).to have_http_status 200
      json = JSON.parse(response.body)
      expect(json['data']['items'].size).to eq(2)
      expect(json['data']['items'][0]['id']).to eq item1.id
      expect(json['data']['items'][1]['id']).to eq item2.id
    end
  end

  describe "create" do
    it "can create an item" do
      expect {
        post '/api/v1/items', params: {amount: 99}
      }.to change {Item.count}.by(+1)
      json = JSON.parse(response.body)
      p json
      expect(json['data']['amount']).to eq(99)
    end
  end
end
