module RailsAdminUploader
  module Asset
    extend ActiveSupport::Concern

    def as_ra_json
      {
        id: id,
        filename: File.basename(image.path),
        size: image_file_size,
        url: image.url,
        thumb_url: image.url(:thumb),
        ra_token: ra_token,
        name: respond_to?(:name) ? name : nil,
        sort: respond_to?(:sort) ? sort : nil
      }
    end
  end
end
