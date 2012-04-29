module Searchable
  class DocumentInstanceAccessor < Sunspot::Adapters::InstanceAdapter
    def id
      @instance.id
    end
  end

  class DocumentDataAccessor < Sunspot::Adapters::DataAccessor
    def load(id)
      Child.get(id)
    end
  end

  def self.included(klass)
    klass.extend ClassMethods
    klass.class_eval do
      after_create :index_record
      after_update :index_record
      after_save :index_record

      def index_record
        begin
          Child.build_solar_schema
          Sunspot.index!(self)
        rescue Exception => e
          puts "***Problem indexing record for searching, is SOLR running?"
          p e
          puts e.message
          puts e.backtrace.inspect
        end
        true
      end
    end
  end

  module ClassMethods
    def sunspot_search(query = "")
      Child.build_solar_schema

      response = Sunspot.search(self) do
        fulltext(query)
        adjust_solr_params do |params|
          params[:defType] = "lucene"
          params[:qf] = nil
        end
      end
      response.results

    end

    def reindex!
      Child.build_solar_schema
      Sunspot.remove_all(self)
      self.all.each { |record| Sunspot.index!(record) }
    end
  end

end
