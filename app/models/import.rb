class Import < ActiveRecord::Base
  mount_uploaders :nomis_exports, FileUploader

  validates :nomis_exports, presence: true
  validate :nomis_exports_uniqueness

  after_create :create_uploads

  def files
    nomis_exports.map { |nomis_export| nomis_export.file.filename }.join(', ')
  end

  private

  def create_uploads
    nomis_exports.each do |nomis_export|
      md5 = md5(nomis_export.file)
      Upload.create(md5: md5)
    end
  end

  def nomis_exports_uniqueness
    nomis_exports.each do |nomis_export|
      md5 = md5(nomis_export.file)
      next unless Upload.where(md5: md5).any?
      errors[:base] << "File #{nomis_export.file.filename} already uploaded"
    end
  end

  def md5(file)
    Digest::MD5.hexdigest file.read.to_s
  end
end
