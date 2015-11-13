module RailsAdminUploader
  class AttachmentsController < ActionController::Base
    before_action :find_obj

    def index
      authorize! :read, @obj
      if @obj.nil?
        render json: []
      else
        @imgs = @obj.send(params[:field]).accessible_by(current_ability)
        if @flags[:sortable]
          @imgs = @imgs.order(sort: :asc)
        end
        @imgs = @imgs.map(&:as_ra_json)
        render json: {files: @imgs}
      end
    end

    def create
      authorize! :read, @obj unless @obj.nil?
      authorize! :create, @asset_klass

      if params[:order]
        sort()
        return
      end

      ret = []
      params[:files].each do |f|
        img = @asset_klass.new(image: f)
        if @obj.nil?
          img.ra_token = params[:guid]
        else
          img.send("#{@asset_fk}=", @obj.id)
        end
        saved = img.save
        data = img.as_ra_json
        unless saved 
          data['error'] = img.errors.full_messages.join()
        end
        ret.push data
        render json: {files: ret}
      end
    end

    def sort
      order = params[:order]
      @obj.send(params[:field]).accessible_by(current_ability).each do |i|
        i.sort = order.index(i.id.to_s)
        i.save!
      end
      render json: {success: true}
    end

    def update
      authorize! :read, @obj unless @obj.nil?
      @img = @obj.send(params[:field]).find(params[:id])
      authorize! :update, @img
      if @img.update_attributes(params.require(:img).permit(:enabled, :name))
        render json: @img.as_ra_json
      else
        render json: {errors: @img.errors.full_messages.join("\n")}, status: 422
      end
    end

    def destroy
      authorize! :read, @obj unless @obj.nil?
      @img = @obj.send(params[:field]).find(params[:id])
      authorize! :destroy, @img
      if @img.destroy
        render json: {success: true}
      else
        render json: {errors: @img.errors.full_messages.join("\n")}, status: 422
      end
    end

    private
    def find_obj
      @klass = params[:klass].safe_constantize
      if @klass.respond_to?(:ra_columns) && @klass.ra_columns.map(&:to_s).include?(params[:field])
        @ref = @klass.ra_get_reflection(params[:field])
        @asset_klass = @ref.klass
        @asset_fk = @ref.foreign_key
        @flags = @klass.ra_flags(params[:field])
        if params[:obj_id]
          @obj = @klass.find(params[:obj_id])
        end
      else
        render json: {error: 'bad OBJ'}, status: 422
      end
    end
  end
end

