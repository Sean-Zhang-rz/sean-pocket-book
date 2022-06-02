require 'rails_helper'
require 'rspec_api_documentation/dsl'

resource "验证码" do
  post "/api/v1/validation_codes" do
    parameter :email, type: :string, required: true, desc: "邮箱"
    let(:email) { ['1@qq.com'] }

    example "请求发送验证码" do
      do_request

      expect(status).to eq 200
      # json = JSON.parse(response_body)
      expect(response_body).to eq ' '
    end
  end
end