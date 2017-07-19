class FileUploader < CarrierWave::Uploader::Base
  def content_type_whitelist
    %w(
      text/csv
      text/comma-separated-values
      application/vnd.ms-excel
      application/vnd.openxmlformats-officedocument.spreadsheetml.sheet
    )
  end

  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{model.id}/#{mounted_as}"
  end

  def md5
    @md5 ||= Digest::MD5.hexdigest model.send(mounted_as).read.to_s
  end
end
