require 'rails_helper'
require 'rspec_api_documentation/dsl'

resource "标签" do
  authentication :basic, :auth
  let(:current_user) { create :user }
  let(:auth) { "Bearer #{current_user.generate_jwt}" }
  get "/api/v1/tags" do
    parameter :page, '页码'
    parameter :kind, '类型', in: ['expenses', 'income ']
    with_options :scope => :data do
      response_field :id, 'ID'
      response_field :name, "名称"
      response_field :sign, "符号"
      response_field :user_id, "用户ID"
      response_field :deleted_at, "删除时间"
    end
    example "获取标签" do
      create_list :tag, Tag.default_per_page + 1, user: current_user
      do_request
      expect(status).to eq 200
      json = JSON.parse(response_body)
      expect(json['data']['tagList'].size).to eq Tag.default_per_page
    end
  end
  get "/api/v1/tags/:id" do
    let (:tag) { create :tag, user: current_user }
    let (:id) { tag.id }
    with_options :scope => :data do
      response_field :id, 'ID'
      response_field :name, "名称"
      response_field :sign, "符号"
      response_field :user_id, "用户ID"
      response_field :deleted_at, "删除时间"
    end
    example "获取单个标签" do
      do_request
      expect(status).to eq 200
      json = JSON.parse(response_body)
      expect(json['data']['id']).to eq tag.id
    end
  end
  post "/api/v1/tags" do
    parameter :name, '名称', required: true
    parameter :sign, '符号', required: true
    parameter :kind, '类别', required: true
    with_options :scope => :data do
      response_field :id, 'ID'
      response_field :name, "名称"
      response_field :sign, "符号"
      response_field :user_id, "用户ID"
      response_field :deleted_at, "删除时间"
    end
    let(:name) { 'x' }
    let(:sign) { 'x' }
    let(:kind) { 'expenses' }
    example "创建标签" do
      do_request
      expect(status).to eq 200
      json = JSON.parse(response_body)
      expect(json['data']['name']).to eq name
      expect(json['data']['sign']).to eq sign
      expect(json['data']['kind']).to eq kind
    end
  end
  patch "/api/v1/tags/:id" do
    let (:tag) { create :tag, user: current_user }
    let (:id) { tag.id }
    parameter :name, '名称' 
    parameter :sign, '符号'
    parameter :kind, '类别', required: true
    with_options :scope => :data do
      response_field :id, 'ID'
      response_field :name, "名称"
      response_field :sign, "符号"
      response_field :user_id, "用户ID"
      response_field :deleted_at, "删除时间"
    end
    let(:name) { 'x' }
    let(:sign) { 'x' }
    let(:kind) { 'expenses' }
    example "修改标签" do
      do_request
      expect(status).to eq 200
      json = JSON.parse(response_body)
      expect(json['data']['name']).to eq name
      expect(json['data']['sign']).to eq sign
    end
  end
  delete "/api/v1/tags/:id" do
    let (:tag) { create :tag, user: current_user }
    let(:id) { tag.id }
    example "删除标签" do
      do_request
      expect(status).to eq 200
    end
  end
end