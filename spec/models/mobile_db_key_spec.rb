require 'spec_helper'

describe MobileDbKey, :type => :model do
  before :each do
    MobileDbKey.all.each { |mdb| mdb.destroy }
  end

  it "should fetch the MobileDBKey for given imei if present" do
    mobile_db_key = MobileDbKey.create(:imei => "1234312", :db_key => "SOME_KEY")
    expect(MobileDbKey.find_or_create_by_imei(mobile_db_key.imei)).to eq(mobile_db_key)
  end

  it "should create a new entry when no matching record found for given imei" do
    expect(SecureRandom).to receive(:hex).with(8).and_return("1234567812345678")
    mobile_db_key = MobileDbKey.find_or_create_by_imei("this is a new imei")
    expect(mobile_db_key.db_key).to eq("1234567812345678")
  end

end
