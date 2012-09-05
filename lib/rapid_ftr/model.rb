require 'delegate'

module RapidFTR
  module Model
    include ActiveModel::Conversion

    def self.included(base)
      base.extend ActiveModel::Naming
    end

    def persisted?
      !new_record?
    end

    def errors
      ErrorsAdapter.new super
    end

    class ErrorsAdapter < SimpleDelegator
      def [](key)
        (__getobj__.respond_to?(:[]) && __getobj__[key]) || []
      end

      def length
        count
      end
    end
  end
end
