class MobileDbKey < CouchRestRails::Document
  use_database :mobile_db_key

  include RapidFTR::Model

  property :imei
  property :db_key

  view_by :imei,
    :map => "function(doc) {
              if ((doc['couchrest-type'] == 'MobileDbKey') && doc['imei'])
             {
                emit(doc['imei'],doc);
             }
          }"

  def self.find_or_create_by_imei(imei)
     mobile_db_key = MobileDbKey.by_imei(:key => imei).first
     mobile_db_key.nil? ? MobileDbKey.create(:imei => imei, :db_key => SecureRandom.hex(8)) : mobile_db_key
  end

end
