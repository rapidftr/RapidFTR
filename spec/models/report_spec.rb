require 'spec_helper'

describe Report, :type => :model do

  it 'should have at least one attachment' do
    report = build :report, :data => nil
    expect(report).not_to be_valid
    expect(report.errors[:must_have_attached_report]).not_to be_empty
  end

  it 'should return file name' do
    report = build :report, :filename => 'test_report.csv'
    expect(report.file_name).to eq('test_report.csv')
  end

  it 'should return content type' do
    report = build :report, :content_type => 'text/csv'
    expect(report.content_type).to eq('text/csv')
  end

  it 'should return data' do
    report = create :report, :data => 'TEST DATA'
    expect(report.data).to eq('TEST DATA')
  end

end
