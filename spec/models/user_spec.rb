require 'rails_helper'

RSpec.describe User, type: :model do
  it '有 email' do
    user = User.new email: 'sean@x.com'
    expect(user.email).to eq 'sean@x.com'
  end
end
