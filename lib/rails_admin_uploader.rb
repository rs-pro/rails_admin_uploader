require "rails_admin_uploader/version"
require 'securerandom'

module RailsAdminUploader
  autoload :Base, 'rails_admin_uploader/base'
  autoload :Asset, 'rails_admin_uploader/asset'

  def self.guid
    SecureRandom.base64(16).tr('+/=', 'xyz').slice(0, 20)
  end
end

require "rails_admin_uploader/field"
require "rails_admin_uploader/engine"

