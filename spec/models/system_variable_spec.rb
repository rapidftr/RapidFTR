require 'spec_helper'

describe SystemVariable, :type => :model do

  before :each do
    SystemVariable.all.all.each(&:destroy)
  end

  describe 'settings' do

    it 'should fail to save if key/name is nil' do
      score_threshold_setting = SystemVariable.new :name => nil, :value => 'value'
      score_threshold_setting.save

      expect(score_threshold_setting).not_to be_valid
    end

    it 'should fail to save if value is null' do
      score_threshold_setting = SystemVariable.new :name => 'SCORE_THRESHOLD', :value => nil
      score_threshold_setting.save

      expect(score_threshold_setting).not_to be_valid
    end

    it 'should fail to save if value and name are both nil' do
      score_threshold_setting = SystemVariable.new :name => nil?, :value => nil
      score_threshold_setting.save

      expect(score_threshold_setting).not_to be_valid
    end

    it 'should fail to save if name already exists' do
      score_threshold_setting = SystemVariable.new :name => 'SCORE_THRESHOLD', :value => '23'
      score_threshold_setting.save
      expect(score_threshold_setting).to be_valid

      setting = SystemVariable.new :name => 'SCORE_THRESHOLD', :value => '2344343'
      setting.save
      expect(setting).not_to be_valid
    end

    it 'should find a setting with a particular name' do
      SystemVariable.create(:name => 'KEY1', :value => '232')
      SystemVariable.create(:name => 'KEY2', :value => '2322')
      SystemVariable.create(:name => 'KEY3', :value => '2322')

      setting = SystemVariable.find_by_name(:KEY1)
      expect(setting.name).to eq('KEY1')
      expect(setting.value).to eq('232')
    end
  end
end
