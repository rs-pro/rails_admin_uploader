module RailsAdminUploader
  class Field < RailsAdmin::Config::Fields::Base
    register_instance_option :partial do
      :rails_admin_uploader
    end
  end
end

RailsAdmin::Config::Fields::Types::register(:rails_admin_uploader, RailsAdminUploader::Field)
