require 'rails_helper'

RSpec.describe Import, type: :model do
  it { is_expected.to validate_presence_of(:nomis_exports) }

  let(:nomis_export) { fixture_file_upload('files/data_1.csv', 'text/csv') }

  describe 'creating a new import' do
    subject { Import.new(nomis_exports: [nomis_export]) }

    before { subject.save! }

    context 'when valid' do
      it 'saves the Import' do
        expect(Import.count).to be 1
      end

      it 'creates 2 upload records with the MD5 hash' do
        expect(Upload.count).to be 1
        expect(Upload.first.md5).to_not be_blank
      end
    end

    context 'when invalid (trying to import a previously used file)' do
      let!(:import) { Import.create(nomis_exports: [nomis_export]) }

      it 'does not create an import record' do
        expect(Import.count).to be 1
      end

      it 'does not create upload records' do
        expect(Upload.count).to be 1
      end

      it 'has a validation error' do
        expect(import.errors.messages).to include(base: ['File data_1.csv already uploaded'])
      end
    end
  end
end
