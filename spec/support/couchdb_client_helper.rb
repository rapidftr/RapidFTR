require 'json'
require 'restclient'

module CouchdbClientHelper
    def get_object(dbname, object_id)
        url = [database_url(dbname), '/', object_id].join
        response = RestClient.get url
        raise "Couchdb client error: #{response.code} - #{response}" if 200 != response.code
        JSON.parse(response)
    end

    def post_object(dbname, object)
        response = RestClient.post database_url(dbname), object.to_json, :content_type => :json
        raise "Couchdb client error: #{response.code} - #{response}" if ![200, 201].include? response.code
        return JSON.parse(response)["id"]
    end

    def database_url dbname
        full_db_name = [COUCHDB_CONFIG[:db_prefix], dbname, COUCHDB_CONFIG[:db_suffix]].join
        [COUCHDB_CONFIG[:host_path], '/', full_db_name].join
    end
end