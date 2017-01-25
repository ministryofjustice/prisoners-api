namespace :import do
  desc 'Retry last import'
  task retry: :environment do
    import = Import.last
    ParseOffenders.call(import.offenders_file.read)
    import.update_attribute(:status, :successful)
    Import.where('id != ?', import.id).destroy_all
  end

  desc 'Remove all imports, uploads and the files'
  task cleanup: :environment do
    Import.destroy_all
    Upload.destroy_all
    directory = Rails.root.join('public', 'uploads', 'import')
    FileUtils.rm_rf(directory)
  end

  desc 'Import sample offender records'
  task sample: :environment do
    file = Rails.root.join('lib', 'assets', 'data', 'data.csv')
    ParseOffenders.call(file.read)
  end

  desc 'Check and notify if no import has been performed in the last 24 hours'
  task check: :environment do
    unless Import.where('created_at > ?', 1.day.ago).any?
      NotificationMailer.import_not_performed.deliver_now
    end
  end

  desc 'Import nicknames from Google nickname-and-diminutive-names-lookup'
  task nicknames: :environment do
    uri = URI('https://raw.githubusercontent.com/carltonnorthern/nickname-and-diminutive-names-lookup/master/names.csv')
    file = Net::HTTP.get(uri)
    ParseNicknames.call(file)
  end
end
