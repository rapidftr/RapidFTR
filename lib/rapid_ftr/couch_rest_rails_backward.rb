# CouchRestRails::Document provide this method, this is not longer support by CouchRest::Model::Base.
# Seems the application use in several classes adding this method as a workaround.

module RapidFTR
  module CouchRestRailsBackward

    def self.included(base)
        base.extend(ClassMethods)
    end

    module ClassMethods
      def paginate(pagination_options = {})
        paginates_per pagination_options[:per_page] if pagination_options[:per_page]
        design_view = eval("self.#{pagination_options[:view_name]}(#{pagination_options}).page(#{pagination_options[:page]})")
        #We need to returns the model object
        result = []
        design_view.each do |model_obj|
          result << model_obj
        end
        result
      end

      def view(view_name, options = {})
        send(view_name, options)
      end
    end

  end
end
