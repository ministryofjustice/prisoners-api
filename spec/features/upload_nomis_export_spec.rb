require 'rails_helper'

RSpec.feature 'Upload NOMIS export', type: :feature do
  before do
    allow(ProcessImportJob).to receive(:perform_later)
    login(:staff)
  end

  context 'with a valid file' do
    scenario 'upload a NOMIS export' do
      visit new_import_path

      attach_file('import_offenders_file', Rails.root.join('spec', 'fixtures', 'files', 'data.csv'))

      click_button 'Import'

      within('table') do
        expect(page).to have_content('data.csv')
      end
    end
  end

  context 'with an invalid file' do
    scenario 'shows an error' do
      visit new_import_path

      attach_file('import_offenders_file', Rails.root.join('spec', 'fixtures', 'files', 'data.txt'))

      click_button 'Import'

      expect(page).to have_content('Offenders file has to be a CSV or Excel spreadsheet file')
    end
  end
end
