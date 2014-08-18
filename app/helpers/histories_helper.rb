module HistoriesHelper

  def history_entry_for_chidlren_field(history, field, change)
    @form_sections = FormSection.all.select { |fs| fs.form.name == Child::FORM_NAME }

    return_partial_hash(change, field, history)
  end

  def history_entry_for(history, field, change)
    @form_sections = FormSection.all

    return_partial_hash(change, field, history)
  end

  def return_partial_hash(change, field, history)
    if field == "photo_keys"
      return {:partial => "shared/histories/photo_history_change",
              :locals => {
                :new_photos => change['added'],
                :deleted_photos => change['deleted'],
                :datetime => @user.localize_date(history['datetime'], "%Y-%m-%d %H:%M:%S %Z"),
                :user_name => history['user_name'],
                :organisation => history['user_organisation']}}

    elsif field == 'recorded_audio'
      return {:partial => "shared/histories/audio_history_change",
              :locals => default_locals_for(history, change)}
    elsif field == 'flag'
      return {:partial => "shared/histories/flag_change",
              :locals => default_locals_for(history, change).merge(:message => new_value_for(history, 'flag_message'))}
    elsif field == 'reunited'
      return {:partial => "shared/histories/reunited_change",
              :locals => default_locals_for(history, change).merge(:message => new_value_for(history, 'reunited_message'))}
    elsif field == 'investigated'
      return {:partial => "shared/histories/investigated_change",
              :locals => default_locals_for(history, change).merge(:message => new_value_for(history, 'investigated_message'))}
    elsif field == 'duplicate'
      return {:partial => "shared/histories/duplicate_change",
              :locals => default_locals_for(history, change).merge(:duplicate_of => new_value_for(history, 'duplicate_of'))}
    elsif field == 'child'
      return {:partial => "shared/histories/record_created",
              :locals => {:organisation => history['user_organisation'], :user_name => history['user_name'], :datetime => @user.localize_date(history['datetime'], "%Y-%m-%d %H:%M:%S %Z")}}
    elsif %w(flag_message reunited_message investigated_message duplicate_of).include? field
      return {}
      # do nothing, because we are already displaying the duplicate_of as a part of duplicate change
    else
      return {:partial => "shared/histories/history_change",
              :locals => default_locals_for(history, change).merge(:field => get_field_display_name(field))}
    end
  end

  private

  def get_field_display_name(field_name)
    @form_sections.each do |form_section|
      field = form_section.get_field_by_name(field_name)
      return field.display_name.humanize unless field.nil?
    end

    field_name.humanize
  end

  def default_locals_for(history, change)
    {
      :from_value => change['from'],
      :to_value => change['to'],
      :datetime => @user.localize_date(history['datetime'], "%Y-%m-%d %H:%M:%S %Z"),
      :user_name => history['user_name'],
      :organisation => history['user_organisation']
    }
  end
end
