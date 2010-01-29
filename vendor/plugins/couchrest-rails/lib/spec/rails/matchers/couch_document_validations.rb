module Spec
  module Rails
    module Matchers
      
      def validate_couchdb_document_format_of(attribute, options)
        return simple_matcher("document model to validate format of :#{attribute} with #{options[:with]}") do |model|
          model.send("#{attribute}=", nil)
          !model.valid? && model.errors.on(attribute)
        end
      end
      
      def validate_couchdb_document_length_of(attribute, options)
        return simple_matcher("document model to validate length of :#{attribute} within
          #{options[:maximum] || 0} to #{options[:minimum] || 'infinity'}") do |model|
          if options[:within]
             model.send("#{attribute}=", 'x' * (options[:within].last + 1))
          else
            if options[:maximum]
              model.send("#{attribute}=", 'x' * (options[:maximum] + 1))
            else
              model.send("#{attribute}=", 'x' * (options[:minimum] - 1))
            end
          end
          !model.valid? && model.errors.on(attribute)
        end
      end
      
      def validate_couchdb_document_presence_of(attribute)
        return simple_matcher("document model to validate presence of :#{attribute}") do |model|
          model.send("#{attribute}=", nil)
          !model.valid? && model.errors.on(attribute)
        end
      end
      
      def validate_couchdb_document_numericality_of(attribute)
        return simple_matcher("document model to validate numericality of :#{attribute}") do |model|
          model.send("#{attribute}=", 'x')
          !model.valid? && model.errors.on(attribute)
        end
      end
      
    end
  end
end