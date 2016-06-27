require 'csv'

namespace :import do
  desc 'Import sample prisoner records'
  task sample: :environment do
    puts 'Importing sample prisoner records...'

    file = Rails.root.join('lib', 'assets', 'data', 'offenders.csv')
    data = CSV.read(file, headers: true)

    data.each do |row|
      p = Prisoner.create!(
        offender_id: (row['OFFENDER_ID'].gsub(/,/, '').strip  rescue nil),
        title: (row['TITLE'].strip rescue nil),
        given_name: (row['FIRST_NAME'].strip rescue nil),
        middle_names: (row['MIDDLE_NAME'].strip rescue nil),
        surname: (row['LAST_NAME'].strip rescue nil),
        suffix: (row['SUFFIX'].strip rescue nil),
        date_of_birth: (Date.parse(row['BIRTH_DATE'].strip) rescue nil),
        gender: (row['SEX_CODE'].strip rescue nil),
        noms_id: (row['NOMS_ID'].strip rescue nil),
        ethnicity_code: (row['ETHNICITY_CODE'].strip rescue nil),
        ethnicity: (row['ETHNICITY'].strip rescue nil),
        cro_number: (row['CRO_NUMBER'].strip rescue nil),
        pnc_number: (row['PNC_NUMBER'].strip rescue nil),
        nationality: (row['NATIONALITY'].strip rescue nil),
        second_nationality: (row['SECOND_NATIONALITY'].strip rescue nil),
        sexual_orientation: (row['SEXUAL_ORIENTATION'].strip rescue nil)
      )

      puts "PRISONER RECORD CREATED: #{p.offender_id}"
    end
  end
end
