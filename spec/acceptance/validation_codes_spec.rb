require 'rails_helper'
require 'rspec_api_documentation/dsl'

resource "验证码" do
  post "/api/v1/validation_codes" do
    parameter :email, type: :string, required: true, desc: "邮箱"
    header "Content-Type", "application/json"
    let(:email) { ['1@qq.com'] }

    example "请求发送验证码" do
      do_request

      expect(status).to eq 200
    end
  end
end