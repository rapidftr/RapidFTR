
class Form

  def initialize hash
    @dict = Dictionary.new

    found_in_schema = []
    Schema.keys_in_order.each do |field|
      if hash.has_key? field
        @dict.push field, hash[field]
          found_in_schema << field
      end
    end

    remaining_fields = hash.keys - found_in_schema
    remaining_fields.sort.each do |field|
      @dict.push field, hash[field]
    end
  end

  def keys
    @dict.keys
  end

  def each &block
    @dict.each &block
  end
  
end