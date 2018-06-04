require 'rails_helper'

RSpec.feature 'Upload NOMIS export', type: :feature do
  before do
    allow(ProcessImportJob).to receive(:perform_later)
    login(:staff)
  end

  context 'with a valid file' do
    scenario 'upload a NOMIS export' do
      visit new_import_path

      attach_file('import_nomis_exports', [Rails.root.join('spec', 'fixtures', 'files', 'data_1.csv')])

      click_button 'Import'

      expect(page).to have_content('Importing files: data_1.csv')
    end
  end

  context 'with an invalid file' do
    scenario 'shows an error' do
      visit new_import_path

      attach_file('import_nomis_exports', [Rails.root.join('spec', 'fixtures', 'files', 'data.txt')])

      click_button 'Import'

      expect(page).to have_content('Nomis exports has to be a CSV file')
    end
  end
end
