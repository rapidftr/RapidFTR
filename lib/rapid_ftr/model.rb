require 'delegate'
require 'active_model'

module RapidFTR
  module Model
    def self.included(base)
      base.extend ActiveModel::Naming
    end

    def persisted?
      !new_record?
    end

    def _id=(new_id)
      self["_id"] = new_id
    end

    def _id
      self["_id"]
    end

    def errors
      ErrorsAdapter.new super
    end

    def logger
      Rails.logger
    end

    class ErrorsAdapter < SimpleDelegator
      def [](key)
        __getobj__[key] || []
      end

      def length
        count
      end
    end
  end
end
