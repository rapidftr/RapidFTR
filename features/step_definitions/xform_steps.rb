When /^I submit the following xform$/ do |xml_payload|
  Tempfile.open( 'cucumber' ) do |tempfile|
    tempfile.write( xml_payload )
    tempfile.close
    
    post_payload = {'xml_submission_file' => ActionController::TestUploadedFile.new( tempfile.path, Mime::XML )}
    visit java_rosa_bridge_submission_path, :post, post_payload
  end
end
