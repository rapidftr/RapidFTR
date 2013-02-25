require 'spec_helper'

describe ReportsController do
  before :each do
    fake_login
  end

  it "should fetch reports" do
    Report.should_receive(:paginate).with(hash_including(:design_doc => "Report")).and_return([])
    get :index
  end

  it "should sort descending by date" do
    Report.should_receive(:paginate).with(hash_including(:view_name => "by_as_of_date", :descending => true)).and_return([])
    get :index
  end

  it "should set default page parameters" do
    Report.should_receive(:paginate).with(hash_including(:per_page => 30, :page => 1)).and_return([])
    get :index
  end

  it "should set page number from request" do
    Report.should_receive(:paginate).with(hash_including(:page => 5)).and_return([ Report.new ])
    get :index, :page => 5
  end

  it "should download report file" do
    report = create :report, :filename => 'test_report.csv', :data => 'test data'
    sleep 1
    get :show, :id => report.id

    response.content_type.should == report.content_type
    response.headers['Content-Disposition'].should be_include 'filename="test_report.csv"'
    response.body.should == 'test data'
  end
end
