# encoding: utf-8

require 'spec_helper'

describe AdminController, :type => :controller do
  before :each do
    fake_admin_login
  end

  after :each do
    I18n.default_locale = :en
  end

  it 'should set the given locale as default' do
    put :update, :locale => 'fr'
    expect(I18n.default_locale).to eq(:fr)
  end

  it 'should flash a update message when the system language is changed and affected by language changed ' do
    put :update, :locale => 'zh'
    expect(flash[:notice]).to eq('设置成功')
    expect(response).to redirect_to(admin_path)
  end
end
