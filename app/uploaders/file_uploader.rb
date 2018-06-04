class FileUploader < CarrierWave::Uploader::Base
  storage :file

  def content_type_whitelist
    ['text/csv', 'text/comma-separated-values', 'application/vnd.ms-excel']
  end

  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{model.id}/#{mounted_as}"
  end
end
