# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def current_url_with_format_of( format )
    url_for( params.merge( 'format' => format, 'escape' => false ) )
  end

  def javascript_tags
    @javascripts.map do |js_file|
     javascript_include_tag(js_file)
    end.join("\n")
  end
end
