require 'spec_helper'

module JavaRosaBridge
  describe FormsController do
    describe '#submission' do
      GENERIC_XFORM = <<EOS
        <xform>
          <age>123</age>
          <weight>heavy</weight>
        </xform>
EOS
      def stub_child
        stub(Child,:save! => nil)
      end

      def upload_xml( xml_string )
        Tempfile.open( 'rspec_java_rosa_form_submission' ) do |tempfile|
          tempfile.write( xml_string )
          tempfile.close
          
          post_payload = {'xml_submission_file' => ActionController::TestUploadedFile.new( tempfile.path, Mime::XML )}
          post :submission, post_payload
        end
      end

      it 'should create a child based on the supplied xform xml' do
        Child.should_receive(:new_with_user_name).with( anything, {'age' => '123', 'weight' => 'heavy' } ).and_return( stub_child )
        upload_xml <<EOS
        <xform>
          <age>123</age>
          <weight>heavy</weight>
        </xform>
EOS
      end

      it 'should save a child to the database' do
        Child.stub(:new_with_user_name).and_return( mock_child = mock(Child) )
        mock_child.should_receive( :save! )
        upload_xml( GENERIC_XFORM )
      end
    end
  end
end
