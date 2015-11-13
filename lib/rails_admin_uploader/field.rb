module RailsAdminUploader
  class Field < RailsAdmin::Config::Fields::Base
    register_instance_option :partial do
      :rails_admin_uploader
    end
    register_instance_option :allowed_methods do
      [:ra_token]
    end
  end
end

RailsAdmin::Config::Fields::Types::register(:rails_admin_uploader, RailsAdminUploader::Field)
