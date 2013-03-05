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
          Rails.env.production? ? Sunspot.index(self) : Sunspot.index!(self)
        rescue
          Rails.logger.error "***Problem indexing record for searching, is SOLR running?"
        end
        true
      end
    end
  end

  module ClassMethods
    def sunspot_search(page_number, query = "")
      Child.build_solar_schema

      begin
        return get_search(page_number, query).results, get_search(nil, query).results
      rescue
        self.reindex!
        Sunspot.commit
        return get_search(page_number, query).results, get_search(nil, query).results
      end

    end

    def reindex!
      Child.build_solar_schema
      Sunspot.remove_all(self)
      self.all.each { |record| Sunspot.index!(record) }
    end

    def get_search(page_number, query)
      response = Sunspot.search(self) do
        fulltext(query)
        without(:duplicate, true)
        paginate :page => page_number, :per_page => page_number.nil? ? :total_count : ::ChildrenHelper::View::PER_PAGE
        adjust_solr_params do |params|
          params[:defType] = "lucene"
          params[:qf] = nil
        end
      end
      response

    end
  end

end
