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

      def stub_out_child_creation
        Child.stub!(:new_with_user_name).
          and_return(stub_child)
      end

      def stub_out_authentication
        stub_user = stub( User,
          :authenticate => true,
          :user_name => 'stub user'
        )
        User.stub!(:find_by_user_name).with('stubbed_username').and_return( stub_user )
        authenticate_with('stubbed_username','')
      end

      def authenticate_with(u,p)
        request.env["HTTP_AUTHORIZATION"] = ActionController::HttpAuthentication::Basic.encode_credentials(u,p)
      end

      def post_submission( xml_string = GENERIC_XFORM )
        Tempfile.open( 'rspec_java_rosa_form_submission' ) do |tempfile|
          tempfile.write( xml_string )
          tempfile.close
          
          post_payload = {'xml_submission_file' => ActionController::TestUploadedFile.new( tempfile.path, Mime::XML )}
          post :submission, post_payload
        end
      end


      before :each do
        stub_out_authentication
      end

      it 'should create a child based on the supplied xform xml' do
        Child.should_receive(:new_with_user_name).with( anything, {'age' => '123', 'weight' => 'heavy' } ).and_return( stub_child )
        post_submission <<EOS
        <xform>
          <age>123</age>
          <weight>heavy</weight>
        </xform>
EOS
      end

      it 'should save a child to the database' do
        Child.stub(:new_with_user_name).and_return( mock_child = mock(Child) )
        mock_child.should_receive( :save! )
        post_submission
      end

      it "should create child using catchall 'anon_javarosa_user' if no basic auth supplied" do
        request.env["HTTP_AUTHORIZATION"] = nil
        
        Child.should_receive(:new_with_user_name).
          with( 'anon_javarosa_user', anything ).
          and_return( stub(Child,:save! => nil ) )

        post_submission
      end

      it 'should return 401 if basic auth describes invalid user' do
        User.stub!(:find_by_user_name).with('invalid user').and_return(nil)
        authenticate_with( 'invalid user', 'password' )
        post_submission
        response.status.should == '401 Unauthorized'
      end

      it 'should return 401 if basic auth describes invalid password' do
        User.stub!(:find_by_user_name).
          with('valid user').
          and_return( stub(User, :authenticate => false ) )
        authenticate_with( 'valid user', 'password' )
        post_submission
        response.status.should == '401 Unauthorized'
      end

      it 'create a child with the user described in the basic auth' do
        authenticated_user = stub( User,
          :authenticate => true,
          :user_name => 'authenticated_user'
        )
        User.stub!(:find_by_user_name).and_return( authenticated_user )

        Child.should_receive(:new_with_user_name).
          with( 'authenticated_user', anything ).
          and_return( stub(Child,:save! => nil ) )

        post_submission
      end

      it 'should authenticate using basic auth' do
        stub_out_child_creation
        
        User.should_receive(:find_by_user_name).
          with( 'the user' ).
          and_return( mock_user = mock(User) )
        mock_user.should_receive(:authenticate).
          with('the password').
          and_return false

        authenticate_with( 'the user', 'the password' )
        post_submission
      end
    end
  end
end
