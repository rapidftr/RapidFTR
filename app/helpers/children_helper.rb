module ChildrenHelper
  module View
    PER_PAGE = 20
    MAX_PER_PAGE = 9999
  end

  module EditView
    ONETIME_PHOTOS_UPLOAD_LIMIT = 5
  end
  ORDER_BY = {'active' => 'created_at', 'all' => 'created_at', 'reunited' => 'reunited_at', 'flag' => 'flag_at'}

  def thumbnail_tag(model, key = nil)
    image_tag(thumbnail_path(model.class.name.downcase, model.id, key || model.current_photo_key, :ts => model.last_updated_at),
              :alt => model['name'])
  end

  def link_to_photo_with_key(key, model)
    link_to thumbnail_tag(model, key),
            photo_path(model.class.name.downcase, model.id, key, :ts => model.last_updated_at),
            :id => key,
            :target => '_blank'
  end

  def link_to_download_audio_with_key(model, key)
    link_to key.humanize, audio_url(model.class.name.downcase, model.id, key), :id => key, :target => '_blank'
  end

  def playable_in_browser?(audio)
    AudioMimeTypes.browser_playable? audio.mime_type
  end

  def audio_url_for(model)
    audio_url(model.class.name.downcase, model.id)
  end

  def link_to_update_info(child)
    link_to('and others', child_history_path(child)) unless child.has_one_interviewer?
  end

  def flag_message
    user = @child.histories.select { |h| h['changes']['flag'] }.first['user_name']
    message = (@child.flag_message.blank? && '') || ": \"#{@child.flag_message}\""
    I18n.t('child.flagged_as_suspected') + " #{user}#{message}"
  end

  def flag_summary_for_child(child)
    flag_history = child['histories'].select { |h| h['changes'].keys.include?('flag') }.first
    '<b>' + I18n.t('child.flagged_by') + ' </b>' + flag_history['user_name'] + '<b> ' + I18n.t('preposition.on_label') + '</b> ' + current_user.localize_date(flag_history['datetime']) + '<b> ' + I18n.t('preposition.because') + '</b> ' + child['flag_message']
  end

  def reunited_message
    'Reunited'
  end

  def duplicate_message
    raw("This record has been marked as a duplicate and is no longer active. To see the Active record click #{link_to 'here', child_path(@child.duplicate_of)}.")
  end

  def field_value_for_display(field_value)
    return '' if field_value.nil? || (field_value.respond_to?(:empty?) && field_value.empty?)
    return field_value.join ', ' if field_value.instance_of? Array
    field_value
  end

  def link_for_filter(filter, selected_filter)
    return filter.capitalize if filter == selected_filter
    link_to(filter.capitalize, child_filter_path(filter))
  end

  def link_for_order_by(filter, order, order_id, selected_order)
    return order_id.capitalize if order == selected_order
    link_to(order_id.capitalize, child_filter_path(:filter => filter, :order_by => order))
  end

  def toolbar_for_child(child)
    if child.duplicate?
      link_to 'View the change log', child_history_path(child)
    else
      render :partial => 'show_child_toolbar'
    end
  end

  def order_options_array_from(system_fields, form_sections)
    system_fields ||= []
    form_sections ||= []
    options = {}
    options[t('children.order_by.system_fields')] = system_fields.map { |f| [t("children.order_by.#{f}"), f] }
    form_sections.each do |form_section|
      options_for_form = form_section.all_sortable_fields.map { |f| [f.display_name, f.name] }
      options[form_section.name] = options_for_form
    end
    options
  end

  def child_sorted_highlighted_fields
    Form.find_by_name(Child::FORM_NAME).sorted_highlighted_fields
  end

  def confirmed_matches_header(matches)
    return nil if matches.empty?
    builder = [t('enquiry.confirmed_matches') + ': ']
    if matches.count == 1
      builder << matches.map { |match| link_to(match.enquiry.short_id, enquiry_path(match.enquiry.id)) }
    else
      builder << matches.take(1).map { |match| link_to(match.enquiry.short_id, enquiry_path(match.enquiry.id)) }
      builder << matches.drop(1).map { |match| link_to(', ' + match.enquiry.short_id, enquiry_path(match.enquiry.id)) }
    end
    content = content_tag(:h3, builder.flatten.join('').html_safe)
    content_tag(:div, content, :id => 'match_details', :class => 'filter_bar')
  end

  def mark_as_not_matching_link(child, confirmed_match, enquiry, options = {})
    return nil if !confirmed_match.nil? && confirmed_match.child == child
    link_path = enquiry_potential_match_path(enquiry.id, child.id, options)
    content = " | #{link_to t('enquiry.mark_child_as_not_matching'), link_path, :method => :delete}".html_safe
    content_tag(:li, content, :id => "mark_#{child.id}")
  end

  def confirm_match_link(child, confirmed_match, enquiry, options = {})
    return nil unless confirmed_match.nil?
    return matched_elsewhere_li_element if enquiry.reunited_elsewhere? || !enquiry.confirmed_match.nil?
    link_path = enquiry_potential_match_path(enquiry.id, child.id, options.merge(:confirmed => true))
    content = " | #{link_to t('enquiry.confirm_child_as_matching'), link_path, :method => :put}".html_safe
    content_tag(:li, content, :id => "confirm_#{child.id}")
  end

  def unconfirm_match_link(child, confirmed_match, enquiry, options = {})
    return nil if confirmed_match.nil? || !(child == confirmed_match.child && enquiry == confirmed_match.enquiry)
    link_path = enquiry_potential_match_path(enquiry.id, child.id, options.merge(:confirmed => false))
    content = " | #{link_to t('enquiry.unmark_child_as_matching'), link_path, :method => :put}".html_safe
    content_tag(:li, content, :id => "confirm_#{child.id}")
  end

  def matched_elsewhere_li_element
    message = content_tag(:div, t('enquiry.matched_elsewhere_link'), :class => 'matched_message')
    content_tag(:li, " |  #{message}".html_safe)
  end

  def child_title(child)
    "#{child_title_fields(child)} (#{child.short_id})".strip
  end

  def child_title_fields(child)
    title_fields = Form.find_by_name(Child::FORM_NAME).title_fields
    title_fields.map { |f| child.send(f.name) } .join(' ')
  end
end
