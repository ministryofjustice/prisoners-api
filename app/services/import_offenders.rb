module ImportOffenders
  def call(import)
    report_log, errors_log = report_and_errors(import)
    if errors_log.any?
      import.update_attribute(:status, :failed)
      import.update_attribute(:error_log, errors_log.join("\n"))
      NotificationMailer.import_failed(import).deliver_later
    else
      import.update_attribute(:status, :successful)
      Import.where('id != ?', import.id).destroy_all
    end
    import.update_attribute(:report_log, report_log.join("\n"))
  end

  module_function :call

  class << self
    private

    def report_and_errors(import)
      report_log = []
      errors_log = []

      import.nomis_exports.each do |nomis_export|
        file = nomis_export.file
        next unless file
        errors = ParseOffenders.call(file.file)
        add_log_entry(errors, report_log, errors_log, file)
      end
      [report_log, errors_log]
    end

    def add_log_entry(errors, report_log, errors_log, file)
      if errors.any?
        report_log << "File #{file.filename} failed to import at #{Time.current}"
        errors_log << "There were some errors in file #{file.filename}"
        errors_log << errors.join("\n")
      else
        report_log << "File #{file.filename} imported at #{Time.current}"
      end
    end
  end
end
