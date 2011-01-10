# Be sure to restart your server when you modify this file.

# Add new inflection rules using the following format 
# (all these examples are active by default):
# ActiveSupport::Inflector.inflections do |inflect|
#   inflect.plural /^(ox)$/i, '\1en'
#   inflect.singular /^(ox)en/i, '\1'
#   inflect.irregular 'person', 'people'
#   inflect.uncountable %w( fish sheep )
# end

module ActiveSupport::Inflector
  # does the opposite of humanize.... mostly. Basically does a
  # space-substituting .underscore
  def dehumanize(the_string)
    result = the_string.to_s.dup
    result.downcase().gsub(/[^0-9a-zA-Z ]/, '').gsub(/ +/,'_').strip()
  end
end
class String
  def dehumanize
    ActiveSupport::Inflector.dehumanize(self)
  end
  def is_number?
    !!(self =~ /^\d*\.{0,1}\d?$/)
  end
end
