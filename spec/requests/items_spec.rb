require 'rails_helper'

RSpec.describe "Items", type: :request do
  describe "账目获取" do
    it "分页" do
      user = create :user
      create_list :item, Item.default_per_page + 1, user:user
      get '/api/v1/items', headers: user.generate_auth_header
      expect(response).to have_http_status(200)
      json = JSON.parse(response.body)
      expect(json['data']['itemsList'].size).to eq(Item.default_per_page)
      get '/api/v1/items?page=2', headers: user.generate_auth_header
      json = JSON.parse(response.body)
      expect(json['data']['itemsList'].size).to eq(1)
    end

    it "按时间筛选" do
      user1 = create :user
      item1 = create :item, happen_at: "2018-01-02", user: user1
      item2 = create :item, happen_at: "2018-01-02", user: user1
      item3 = create :item, happen_at: "2019-01-01", user: user1
      get '/api/v1/items?happen_after=2018-01-01&happen_before=2018-01-02', headers: user1.generate_auth_header
      expect(response).to have_http_status 200
      json = JSON.parse(response.body)
      expect(json['data']['itemsList'].size).to eq(2)
      expect(json['data']['itemsList'][0]['id']).to eq item1.id
      expect(json['data']['itemsList'][1]['id']).to eq item2.id
    end
    it "按时间筛选(边界)" do
      user1 = create :user
      item3 = create :item, happen_at: "2018-01-02", user: user1
      get '/api/v1/items?happen_after=2018-01-01&happen_before=2018-01-02', headers: user1.generate_auth_header
      expect(response).to have_http_status 200
      json = JSON.parse(response.body)
      expect(json['data']['itemsList'].size).to eq(1)
    end
    it "按时间筛选(边界2)" do
      user1 = create :user
      item1 = create :item, happen_at: "2018-01-01", user: user1
      item2 = create :item, happen_at: "2019-01-01", user: user1
      get '/api/v1/items?happen_before=2018-01-02', headers: user1.generate_auth_header
      expect(response).to have_http_status 200
      json = JSON.parse(response.body)
      expect(json['data']['itemsList'].size).to eq(1)
      expect(json['data']['itemsList'][0]['id']).to eq item1.id
    end
    it "按 kind 筛选" do
      user = create :user
      create :item, kind: 'income', amount: 200, user: user
      create :item, kind: 'expenses', amount: 100, user: user

      get "/api/v1/items?kind=income", headers: user.generate_auth_header
      expect(response).to have_http_status 200
      json = JSON.parse(response.body)
      expect(json["data"]['itemsList'].size).to eq 1
      expect(json["data"]['itemsList'][0]["amount"]).to eq 200
    end
  end

  describe "创建账目" do
    it "未登录创建" do
      post '/api/v1/items', params: {amount: 100}
      expect(response).to have_http_status 401
    end
    it "登录创建" do
      user1 = create :user
      tag1 = create :tag, user: user1
      tag2 = create :tag, user: user1
      expect {
        post '/api/v1/items', params: {amount: 99, tag_ids: [tag1.id, tag2.id], kind: 'expenses', happen_at: '2018-01-01T00:00:00+08:00'}, headers: user1.generate_auth_header
      }.to change {Item.count}.by 1
      json = JSON.parse(response.body)
      expect(json['data']['id']).to be_an(Numeric)
      expect(json['data']['amount']).to eq(99)
      expect(json['data']['user_id']).to eq user1.id
    end
    it "创建 amount 必填" do
      user1 = create :user
      post '/api/v1/items', params: {}, headers: user1.generate_auth_header
      expect(response).to have_http_status 422
      json = JSON.parse(response.body)
      expect(json['msg']).to eq "金额不可为空"
    end
  end
  describe "统计分组" do
    it '按天分组' do
      user = User.create! email: '1@qq.com'
      tag = Tag.create! name: 'tag1', sign: 'x', kind: 'expenses',  user_id: user.id
      Item.create! amount: 100, kind: 'expenses', tag_ids: [tag.id], happen_at: '2018-06-18T00:00:00+08:00', user_id: user.id
      Item.create! amount: 200, kind: 'expenses', tag_ids: [tag.id], happen_at: '2018-06-18T00:00:00+08:00', user_id: user.id
      Item.create! amount: 100, kind: 'expenses', tag_ids: [tag.id], happen_at: '2018-06-20T00:00:00+08:00', user_id: user.id
      Item.create! amount: 200, kind: 'expenses', tag_ids: [tag.id], happen_at: '2018-06-20T00:00:00+08:00', user_id: user.id
      Item.create! amount: 100, kind: 'expenses', tag_ids: [tag.id], happen_at: '2018-06-19T00:00:00+08:00', user_id: user.id
      Item.create! amount: 200, kind: 'expenses', tag_ids: [tag.id], happen_at: '2018-06-19T00:00:00+08:00', user_id: user.id
      get '/api/v1/items/summary', params: {
        happened_after: '2018-01-01',
        happened_before: '2019-01-01',
        kind: 'expenses',
        group_by: 'happen_at'
      }, headers: user.generate_auth_header
      expect(response).to have_http_status 200
      json = JSON.parse response.body
      expect(json['data']['groups'].size).to eq 3
      expect(json['data']['groups'][0]['happen_at']).to eq '2018-06-18'
      expect(json['data']['groups'][0]['amount']).to eq 300
      expect(json['data']['groups'][1]['happen_at']).to eq '2018-06-19'
      expect(json['data']['groups'][1]['amount']).to eq 300
      expect(json['data']['groups'][2]['happen_at']).to eq '2018-06-20'
      expect(json['data']['groups'][2]['amount']).to eq 300
      expect(json['data']['total']).to eq 900
    end
    it '按tag_id分组' do
      user = User.create! email: '1@qq.com'
      tag1 = Tag.create! name: 'tag1', sign: 'x', kind: 'expenses', user_id: user.id
      tag2 = Tag.create! name: 'tag2', sign: 'x', kind: 'expenses',  user_id: user.id
      tag3 = Tag.create! name: 'tag3', sign: 'x', kind: 'expenses',  user_id: user.id
      Item.create! amount: 100, kind: 'expenses', tag_ids: [tag1.id, tag2.id], happen_at: '2018-06-18T00:00:00+08:00', user_id: user.id
      Item.create! amount: 200, kind: 'expenses', tag_ids: [tag2.id, tag3.id], happen_at: '2018-06-18T00:00:00+08:00', user_id: user.id
      Item.create! amount: 300, kind: 'expenses', tag_ids: [tag3.id, tag1.id], happen_at: '2018-06-20T00:00:00+08:00', user_id: user.id
    
      get '/api/v1/items/summary', params: {
        happened_after: '2018-01-01',
        happened_before: '2019-01-01',
        kind: 'expenses',
        group_by: 'tag_id'
      }, headers: user.generate_auth_header
      expect(response).to have_http_status 200
      json = JSON.parse response.body
      expect(json['data']['groups'].size).to eq 3
      expect(json['data']['groups'][0]['tag_id']).to eq tag3.id
      expect(json['data']['groups'][0]['amount']).to eq 500
      expect(json['data']['groups'][1]['tag_id']).to eq tag1.id
      expect(json['data']['groups'][1]['amount']).to eq 400
      expect(json['data']['groups'][2]['tag_id']).to eq tag2.id
      expect(json['data']['groups'][2]['amount']).to eq 300
      expect(json['data']['total']).to eq 600
    end
  end

  describe "获取余额" do
    it "未登录" do
      get "/api/v1/items/balance?happen_after=2018-01-01&happen_before=2019-01-01"
      expect(response).to have_http_status 401
    end
    it "登录" do
      user = create :user
      create :item, user: user, kind: 'expenses', amount: 100, happen_at: '2018-03-02T16:00:00.000Z'
      create :item, user: user, kind: 'expenses', amount: 200, happen_at: '2018-03-02T16:00:00.000Z'
      create :item, user: user, kind: 'income', amount: 100, happen_at: '2018-03-02T16:00:00.000Z'
      create :item, user: user, kind: 'income', amount: 200, happen_at: '2018-03-02T16:00:00.000Z'

      get "/api/v1/items/balance?happen_after=2018-03-02T15:00:00.000Z&happen_before=2018-03-02T17:00:00.000Z", headers: user.generate_auth_header
      expect(response).to have_http_status 200
      json = JSON.parse(response.body)
      expect(json['data']["income"]).to eq 300
      expect(json['data']["expenses"]).to eq 300
      expect(json['data']["balance"]).to eq 0
    end
  end
end
