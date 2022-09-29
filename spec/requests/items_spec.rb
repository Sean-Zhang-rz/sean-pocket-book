require 'rails_helper'

RSpec.describe "Items", type: :request do
  describe "账目获取" do
    it "分页" do
      11.times do
        Item.create amount: 100
      end
      expect(Item.count).to eq(11)
      get '/api/v1/items'
      expect(response).to have_http_status(200)
      json = JSON.parse(response.body)
      expect(json['data']['items'].size).to eq(5)
      get '/api/v1/items?page=3'
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
