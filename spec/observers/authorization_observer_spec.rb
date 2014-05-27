require 'spec_helper'

describe AuthorizationObserver do
  let(:authorization) { create(:authorization, user: create(:user, facebook_url: 'http://facebook.com/raimcanada')) }

  it 'should set facebook_url to nil' do
    user = authorization.user
    expect(user.facebook_url).to eq 'http://facebook.com/raimcanada'
    authorization.destroy
    user.reload
    expect(user.facebook_url).to be_nil
  end
end
