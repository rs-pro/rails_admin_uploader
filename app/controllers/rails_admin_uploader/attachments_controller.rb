module RailsAdminUploader
  class AttachmentsController < ActionController::Base
    before_action :find_obj

    def index
      if @obj.nil?
        render json: []
      else
        render json: @obj.send(params[:field]).map(&:as_ra_json)
      end
    end

    private
    def find_obj
      @klass = params[:klass].safe_constantize
      if @klass.respond_to?(:ra_columns) && @klass.ra_columns.map(&:to_s).include?(params[:field])
        @asset_klass = @klass.ra_get_reflection(params[:field])
        if params[:id]
          @obj = @klass.find(params[:id])
        end
      else
        render json: {error: 'bad OBJ'}, status: 422
      end
    end
  end
end

