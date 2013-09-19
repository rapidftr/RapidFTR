module MultiJson
  class Adapter
    class << self
      alias_method :original_load, :load

      def load(string, options={})
        string = string.force_encoding('UTF-8')
        original_load(string, options)
      end
    end
  end
end
