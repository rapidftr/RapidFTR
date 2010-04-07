class RelationsSection
  attr_reader :fields

  def self.for(relations)
    new(relations) 
  end

  def initialize( relations )
    @fields = map_relations_to_fields(relations)
  end

  def section_name
    'Relatives'
  end

  private

  def map_relations_to_fields( relations )
    relations.map{ |relation| RelationField.new( relation ) }
  end

  class RelationField
    def initialize(relation)
      @relation = relation
    end

    def name
      @relation['type']
    end

    def value
      reunite_text = @relation['reunite'] ? '(reunite)' : '(do not reunite)'
      "#{@relation['name']} #{reunite_text}"
    end

    def type
      'relationship_field'
    end
  end
end
