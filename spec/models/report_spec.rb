require 'spec_helper'

describe Report do

  it 'should have at least one attachment' do
    report = build :report, :data => nil
    report.should_not be_valid
    report.errors.on(:must_have_attached_report).should_not be_empty
  end

  it 'should return file name' do
    report = build :report, :filename => 'test_report.csv'
    report.file_name.should == 'test_report.csv'
  end

  it 'should return content type' do
    report = build :report, :content_type => 'text/csv'
    report.content_type.should == 'text/csv'
  end

  it 'should return data' do
    report = create :report, :data => 'TEST DATA'
    report.data.should == 'TEST DATA'
  end

end
