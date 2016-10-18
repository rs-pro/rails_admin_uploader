module RailsAdminUploader
  module Base
    extend ActiveSupport::Concern

    included do
      cattr_accessor :ra_columns
      after_create :ra_build_links!
    end

    def ra_set_token!
      self.ra_token = RailsAdminUploader.guid if ra_token.blank?
    end

    def ra_build_links!
      return if ra_token.blank?
      self.class.ra_columns.each do |column|
        ref = self.class.ra_get_reflection(column)
        fk = ref.foreign_key
        ref.klass.where(ra_token: ra_token).each do |obj|
          obj.send("#{fk}=", id)
          obj.ra_token = nil
          obj.save!
        end
      end
      update_column('ra_token', nil)
    end

    module ClassMethods
      def rails_admin_uploader(*columns)
        self.ra_columns = columns
      end

      def ra_get_reflection(column)
        self.reflections[column.to_s]
      end

      def ra_flags(column)
        ref = ra_get_reflection(column).klass
        obj = ref.new
        {
          nameable: obj.respond_to?(:name),
          sortable: obj.respond_to?(:sort),
          enableable: obj.respond_to?(:enabled)
        }
      end
    end
  end
end
