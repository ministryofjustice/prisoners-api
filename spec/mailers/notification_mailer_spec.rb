require 'rails_helper'

RSpec.describe NotificationMailer, type: :mailer do
  let!(:host) { 'somedomain.com' }

  before do
    allow(ENV).to receive(:[]).with('HTTP_HOST').and_return(host)
  end

  describe '#import_failed' do
    let(:import) { instance_double('Import') }
    let(:mailer) { described_class.import_failed(import).deliver_now }

    before(:each) do
      allow(import).to receive(:created_at).and_return(Time.now)
      allow(import).to receive(:nomis_exports).and_return(['file_path'])
      allow(import).to receive(:report_log).and_return('File data_1.csv failed')
      allow(import).to receive(:error_log).and_return('Errors in file')
    end

    it 'renders the subject' do
      expect(mailer.subject).to eq("Import failed (#{host})")
    end

    it 'renders the receiver email' do
      expect(mailer.to).to eq(['single-offender-identity@digital.justice.gov.uk'])
    end

    it 'renders the sender email' do
      expect(mailer.from).to eq(['single-offender-identity@digital.justice.gov.uk'])
    end
  end

  describe '#import_not_performed' do
    let(:mailer) { described_class.import_not_performed.deliver_now }

    it 'renders the subject' do
      expect(mailer.subject).to eq("Import not performed in the last 24 hours (#{host})")
    end

    it 'renders the receiver email' do
      expect(mailer.to).to eq(['single-offender-identity@digital.justice.gov.uk'])
    end

    it 'renders the sender email' do
      expect(mailer.from).to eq(['single-offender-identity@digital.justice.gov.uk'])
    end
  end
end
