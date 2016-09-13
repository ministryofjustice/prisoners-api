module ImportPrisoners
  module_function

  def call(import)
    ParseCsv.call(import.prisoners_file.read)
    ParseCsv.call(import.aliases_file.read)
    import.update_attribute(:status, :successful)
    Import.where('id != ?', import.id).destroy_all
  rescue Exception => e
    import.update_attribute(:status, :failed) if import
    NotificationMailer.import_failed(import, e.to_s).deliver_now
  end
end
