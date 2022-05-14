require 'rails_helper'

RSpec.describe "Items", type: :request do
  describe "GET /items" do
    it "works! (now write some real specs)" do
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
