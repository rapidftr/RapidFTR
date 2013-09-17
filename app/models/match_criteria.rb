class MatchCriteria

  SOLR_SPECIAL_CHARS = %w{@ # ! % $ \ ^ -}

  @criteria = []

  def self.dismax_query(criteria_hash)
    criteria_hash.values.each do |value|
      phrases = value.split(/\s+OR\s+/i)
      phrases.map do |phrase|
        query = sanitize_phrase(phrase)
        query = query.map { |word| "(#{word.downcase}~ OR #{word.downcase}*)" }.join(" OR ")
        @criteria.push("#{query}")
      end
    end
    @criteria.join(" OR ")
  end

  private

  def self.sanitize_phrase(phrase)
    query = phrase.split(/[ ,]+/) - SOLR_SPECIAL_CHARS
    query = query.delete_if { |word| word.empty? }
    query.map { |word| word.sub!(/^[@#!%$\^-]+/, '') || word }
  end
end

