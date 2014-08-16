require 'spec_helper'

describe ReportsController, :type => :controller do
  before :each do
    fake_login_as [Permission::REPORTS[:view]]
  end

  it "should fetch reports" do
    expect(Report).to receive(:paginate).with(hash_including(:design_doc => "Report")).and_return([])
    get :index
  end

  it "should sort descending by date" do
    expect(Report).to receive(:paginate).with(hash_including(:view_name => "by_as_of_date", :descending => true)).and_return([])
    get :index
  end

  it "should set default page parameters" do
    expect(Report).to receive(:paginate).with(hash_including(:per_page => 30, :page => 1)).and_return([])
    get :index
  end

  it "should set page number from request" do
    expect(Report).to receive(:paginate).with(hash_including(:page => 5)).and_return([Report.new])
    get :index, :page => 5
  end

  it "should download report file" do
    report = create :report, :filename => 'test_report.csv', :data => 'test data'
    sleep 1
    get :show, :id => report.id

    expect(response.content_type).to eq(report.content_type)
    expect(response.headers['Content-Disposition']).to be_include 'filename="test_report.csv"'
    expect(response.body).to eq('test data')
  end

  describe '#permissions' do
    before :each do
      fake_field_worker_login
    end

    it "should not list reports" do
      get :index
      expect(response).to be_forbidden
    end

    it "should not download report" do
      report = create :report
      sleep 1
      get :show, :id => report.id
      expect(response).to be_forbidden
    end
  end
end
