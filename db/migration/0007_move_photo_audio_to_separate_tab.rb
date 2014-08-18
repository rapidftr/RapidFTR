photos_and_audio_fs = FormSection.by_unique_id(:key => 'photos_and_audio').first

unless photos_and_audio_fs
  photos_and_audio_fs = FormSection.new('visible' => true,
                          :order => 10, :unique_id => 'photos_and_audio',
                          :perm_visible => true, 'editable' => false,
                          'name_all' => 'Photos and Audio',
                          'description_all' => 'All Photo and Audio Files Associated with a Child Record'
                        )
  basic_identity_fs = FormSection.by_unique_id(:key => 'basic_identity').first

  media_fields = basic_identity_fs.fields.select { |ff| ff.type == 'photo_upload_box' || ff.type == 'audio_upload_box' }
  media_fields.each do |ff|
    photos_and_audio_fs.fields << ff
    basic_identity_fs.fields.delete ff
  end

  basic_identity_fs.fields.reject(&:valid?).each do |ff|
    logger.error(ff.inspect)
    logger.error(ff.errors.inspect)
    logger.error('*' * 25)
  end

  basic_identity_fs.save!
  photos_and_audio_fs.save!
end
