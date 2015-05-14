require 'spec_helper'

describe Permission, :type => :model do

  context 'enquiries feature turned off' do
    before :each do
      SystemVariable.all.each { |variable| variable.destroy }
      SystemVariable.create!(:name => SystemVariable::ENABLE_ENQUIRIES, :type => 'boolean', :value => '0')
    end

    it 'should not return enquiry permissions' do
      expect(Permission.all).not_to include('Enquiries')
      expect(Permission.hashed_values).not_to include('Enquiries')
    end

    it 'should not return potential matches permissions' do
      expect(Permission.all).not_to include('PotentialMatches')
      expect(Permission.hashed_values).not_to include('Enquiries')
    end
  end
end
