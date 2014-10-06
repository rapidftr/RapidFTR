require 'spec_helper'

describe StandardFormsService do
  describe '#persist' do
    before :each do
      reset_couchdb!
    end

    describe 'saving forms' do
      it 'should persist enquiry form' do
        attributes = {'forms' => {
          'children' => {'user_selected' => '0', 'id' => 'children'},
          'enquiries' => {'user_selected' => '1', 'id' => 'enquiries'}}}
        StandardFormsService.persist(attributes)
        expect(Form.all.all.length).to eq 1
        expect(Form.all.first.name).to eq Enquiry::FORM_NAME
      end

      it 'should persist child form' do
        attributes = {'forms' => {
          'children' => {'user_selected' => '1', 'id' => 'children'},
          'enquiries' => {'user_selected' => '0', 'id' => 'enquiries'}}}
        StandardFormsService.persist(attributes)
        expect(Form.all.all.length).to eq 1
        expect(Form.all.first.name).to eq Child::FORM_NAME
      end

      it 'should save both forms 'do
        attributes = {'forms' => {
          'children' => {'user_selected' => '1', 'id' => 'children'},
          'enquiries' => {'user_selected' => '1', 'id' => 'enquiries'}}}
        StandardFormsService.persist(attributes)
        expect(Form.all.all.length).to eq 2
        expect(Form.all.map(&:name)).to include(Child::FORM_NAME, Enquiry::FORM_NAME)
      end

      it 'should not add already existing forms' do
        create :form, :name => Child::FORM_NAME
        attributes = {'forms' => {
          'children' => {'user_selected' => '0', 'id' => 'children',
                          'sections' => {'basic_identity' => {'user_selected' => '1', 'id' => 'basic_identity'}}}}}
        expect { StandardFormsService.persist(attributes) } .to_not change(Form, :count).from(1)
      end
    end

    describe 'saving form sections' do
      it 'should persist new form with new form sections' do
        attributes = {'forms' => {
          'children' => {'user_selected' => '1', 'id' => 'children',
                          'sections' => {
                            'Basic Identity' => {
                              'user_selected' => '1',
                              'id' => 'basic_identity'}
                          }}}}

        StandardFormsService.persist(attributes)

        expect(Form.count).to eq 1
        expect(FormSection.count).to eq 1
        expect(FormSection.all.first.unique_id).to eq('basic_identity')
        expect(FormSection.all.first.name).to eq('Basic Identity')
      end

      it 'should persist new enquiry form with new enquiry criteria form sections' do
        attributes = {'forms' => {
          'enquiries' => {'user_selected' => '1', 'id' => 'enquiries',
                            'sections' => {
                              'Details of the Adult Seeking a Child' => {
                                'user_selected' => '1',
                                'id' => 'enq_details_of_adult_seeking_child',
                                'fields' => {'enq_first_name' => {'user_selected' => '1', 'id' => 'enq_first_name'},
                                             'criteria' => {'user_selected' => '1', 'id' => 'criteria'}
                            }}}}}}

        StandardFormsService.persist(attributes)

        expect(Form.count).to eq 1
        expect(Form.first.sections.length).to eq 1
        expect(FormSection.count).to eq 1
        expect(FormSection.all.first.unique_id).to eq('enq_details_of_adult_seeking_child')
        expect(FormSection.all.first.form).to_not be_nil
        expect(FormSection.all.first.name).to eq('Details of the Adult Seeking a Child')
      end

      it 'should persist new form sections on existing forms with no form sections' do
        create :form, :name => Child::FORM_NAME
        attributes = {'forms' => {
          'children' => {'user_selected' => '0', 'id' => 'children',
                          'sections' => {
                            'Basic Identity' => {
                              'user_selected' => '1',
                              'id' => 'basic_identity'}
                          }}}}

        expect { StandardFormsService.persist(attributes) } .to_not change(Form, :count).from(1)
        expect(FormSection.count).to eq 1
        expect(FormSection.all.first.name).to eq('Basic Identity')
        expect(FormSection.all.first.unique_id).to eq('basic_identity')
      end

      it 'should persist new form sections on existing forms with form sections' do
        form = create :form, :name => Child::FORM_NAME
        create :form_section, :form => form, :unique_id => 'basic_identity', :name => 'Basic Identity'

        attributes = {
          'forms' => {
            'children' => {
              'user_selected' => '0',
              'id' => 'children',
              'sections' => {
                'Photos and Audio' => {
                  'user_selected' => '1',
                  'id' => 'photos_and_audio'
                }
              }
            }
          }
        }

        expect { StandardFormsService.persist(attributes) } .to_not change(Form, :count).from(1)
        expect(FormSection.count).to eq 2
        expect(FormSection.by_unique_id.key('photos_and_audio').first).to_not be_nil
      end

      it 'should persist new form sections on existing forms with existing form sections that have the same name' do
        form = create :form, :name => Child::FORM_NAME
        create :form_section, :form => form, :unique_id => 'basic_identity', :name => 'Basic Identity'

        attributes = {
          'forms' => {
            'children' => {
              'user_selected' => '0',
              'id' => 'children',
              'sections' => {
                'Basic Identity' => {
                  'user_selected' => '1',
                  'id' => 'basic_identity'
                }}}}}

        expect { StandardFormsService.persist(attributes) } .to_not change(Form, :count).from(1)
        expect(FormSection.count).to eq 1
        expect(FormSection.by_unique_id.key('basic_identity').first).to_not be_nil
      end
    end

    describe 'saving fields' do
      it 'should persist new form with new form sections with all fields' do
        attributes = {'forms' => {
          'children' => {
            'user_selected' => '1',
            'id' => 'children',
            'sections' => {
              'Basic Identity' => {
                'user_selected' => '1',
                'id' => 'basic_identity'
              }}}}}

        StandardFormsService.persist(attributes)

        expect(Form.count).to eq 1
        expect(FormSection.count).to eq 1
        section = FormSection.first
        expect(section.unique_id).to eq('basic_identity')
        expect(section.name).to eq('Basic Identity')
        expect(section.fields.length).to eq 17
        expect(section.fields.map(&:name)).to include('name',
                                                      'protection_status',
                                                      'ftr_status',
                                                      'why_record_invalid',
                                                      'id_document',
                                                      'rc_id_no',
                                                      'icrc_ref_no',
                                                      'gender',
                                                      'nick_name',
                                                      'names_origin',
                                                      'date_of_birth',
                                                      'birthplace',
                                                      'nationality',
                                                      'ethnicity_or_tribe',
                                                      'languages',
                                                      'characteristics',
                                                      'documents')
      end

      it 'should persist existing form with new form sections with all fields' do
        create :form, :name => Child::FORM_NAME
        attributes = {'forms' => {
          'children' => {
            'user_selected' => '0',
            'id' => 'children',
            'sections' => {
              'Basic Identity' => {
                'user_selected' => '1',
                'id' => 'basic_identity'
              }}}}}

        StandardFormsService.persist(attributes)

        expect(Form.count).to eq 1
        expect(FormSection.count).to eq 1
        section = FormSection.first
        expect(section.unique_id).to eq('basic_identity')
        expect(section.name).to eq('Basic Identity')
        expect(section.fields.length).to eq 17
        expect(section.fields.map(&:name)).to include('name',
                                                      'protection_status',
                                                      'ftr_status',
                                                      'why_record_invalid',
                                                      'id_document',
                                                      'rc_id_no',
                                                      'icrc_ref_no',
                                                      'gender',
                                                      'nick_name',
                                                      'names_origin',
                                                      'date_of_birth',
                                                      'birthplace',
                                                      'nationality',
                                                      'ethnicity_or_tribe',
                                                      'languages',
                                                      'characteristics',
                                                      'documents')
      end
    end
  end
end
