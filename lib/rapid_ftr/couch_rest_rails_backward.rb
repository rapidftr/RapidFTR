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
        convert_to_model(design_view)
      end

      def view(view_name, options = {})
        # CouchRestRails::Document returns the instance model
        # so do the same thing for compatibility.
        convert_to_model(send(view_name, options))
      end

      #This method convert the docs in the design view
      #to the object model.
      def convert_to_model(design_view)
        result = []
        design_view.each do |instance|
          result << instance
        end
        result
      end

    end
  end
end
