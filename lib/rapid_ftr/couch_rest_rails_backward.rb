# CouchRestRails::Document provide this method, this is not longer support by CouchRest::Model::Base.
# Seems the application use in several classes adding this method as a workaround.
#require 'date'

module RapidFTR
  module CouchRestRailsBackward

    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods

      def paginate(pagination_options = {})
        options = pagination_options.clone
        paginates_per options.delete(:per_page)
        view_name = options.delete(:view_name)
        page = options.delete(:page)
        send(view_name.to_sym, options).page(page).all
      end

      def view(view_name, options = {})
        send(view_name, options).all
      end

    end
  end
end
