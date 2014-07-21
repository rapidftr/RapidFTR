require 'progress_bar'
require 'base64'

rows = Child.database.all_docs['rows']
progressbar = ProgressBar.new rows.count
errors = []

rows.each do |row|
  begin
    doc = Child.database.get row['id']
    attachments = doc['_attachments']
    attachments.each do |attachment_id, attachment_meta|
      if attachment_meta['content_type'].start_with? 'image/'
        data = Child.database.fetch_attachment doc, attachment_id
        begin
          MiniMagick::Image.read data
        rescue MiniMagick::Invalid
          data64 = Base64.decode64 data
          MiniMagick::Image.read data64
          Child.database.put_attachment doc, attachment_id, data64
          doc = Child.database.get row['id']
        end
      end
    end if doc['_attachments']
  rescue => e
    if errors.count == 0
      puts
      puts "Logging the first error, further errors will be suppressed"
      puts e.message
      puts e.backtrace
    end

    errors << row['id']
  end

  progressbar.increment!
end

if errors.count > 0
  puts
  puts "Failed to migrate images for following records:"
  puts errors
  raise "Migration failed" unless ENV['IGNORE_0012'] == 'true'
end
