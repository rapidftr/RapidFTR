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
        return paginated_and_full_results(page_number, query)
      rescue
        self.reindex!
        Sunspot.commit
        return paginated_and_full_results(page_number, query)
      end

    end

    def paginated_and_full_results(page_number, query)
      full_result = []
      get_search(nil, query).hits.each do |hit|
        full_result.push hit.to_param
      end
      return get_search(page_number, query).results, full_result
    end

    def reindex!
      Child.build_solar_schema
      Sunspot.remove_all(self)
      self.all.each { |record| Sunspot.index!(record) }
    end

    def get_search(page_number, query)
      response = Sunspot.search(self) do |q|
        q.fulltext(query)
        q.without(:duplicate, true)
        if page_number
          q.paginate :page => page_number, :per_page => ::ChildrenHelper::View::PER_PAGE
        else
          q.paginate :per_page => ::ChildrenHelper::View::MAX_PER_PAGE
        end
        q.adjust_solr_params do |params|
          params[:defType] = "lucene"
          params[:qf] = nil
        end
      end
      response
    end


    def sunspot_matches(query = "")
      Child.build_solar_schema

      begin
        return get_matches(query).results
      rescue
        self.reindex!
        Sunspot.commit
        return get_matches(query).results
      end
    end

    def get_matches(criteria)
      Sunspot.search(self) do
        fulltext(criteria, :minimum_match => 1)
        adjust_solr_params do |params|
          params[:defType] = "dismax"
        end
      end
    end
  end

end
