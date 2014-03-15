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

      #This method returns a CouchRest::Model::Designs::View
      #If we want the object model, use view_raw.
      def view(view_name, options = {})
        send(view_name, options)
      end

      #This method returns the object model instead the view.
      def view_raw(view_name, options = {})
        convert_to_model(send(view_name, options))
      end

      #This method convert the docs in the design view
      #to the object model.
      def convert_to_model(design_view)
        result = []
        design_view.each do |model_obj|
          result << model_obj
        end
        result
      end

    end
  end
end
