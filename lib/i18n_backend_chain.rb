module I18n
  module Backend
    class CustomChain < I18n::Backend::Chain
      # According to the github post https://github.com/fnando/i18n-js/issues/59
      def initialized?
        backends.each do |backend|
          return false unless backend.initialized?
        end
        return true
      end

      protected

      def init_translations
        backends.each do |backend|
          backend.instance_eval do
            init_translations
          end
        end
      end

      def translations
        trans = {}
        backends.reverse.each do |backend| # reverse so that the top most will be merged-in
          backend.instance_eval do
            trans.deep_merge!(translations)
          end
        end
        return trans
      end

    end
  end
end
