require 'rails_helper'

RSpec.describe ProcessImportJob, type: :job do
  let(:nomis_export) { fixture_file_upload('files/data_1.csv', 'text/csv') }
  let(:import) { Import.create(nomis_exports: [nomis_export]) }

  it 'invokes ImportOffenders service' do
    expect(ImportOffenders).to receive(:call).with(import)
    described_class.new.perform(import)
  end
end
