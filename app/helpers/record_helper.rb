module RecordHelper
  include RapidFTR::Model
  include RapidFTR::Clock

  def set_creation_fields_for(user)
    self['created_by'] = user.try(:user_name)
    self['created_organisation'] = user.try(:organisation)
    self['created_at'] ||= RapidFTR::Clock.current_formatted_time
    self['posted_at'] = RapidFTR::Clock.current_formatted_time
  end

  def update_organisation
    self['created_organisation'] ||= created_by_user.try(:organisation)
  end

  def created_by_user
    User.find_by_user_name self['created_by'] unless self['created_by'].to_s.empty?
  end

  def set_updated_fields_for(user_name)
    self['last_updated_by'] = user_name
    self['last_updated_at'] = RapidFTR::Clock.current_formatted_time
  end

  def last_updated_by
    self['last_updated_by'] || self['created_by']
  end

  def last_updated_at
    self['last_updated_at'] || self['created_at']
  end
end