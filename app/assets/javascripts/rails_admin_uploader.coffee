#= require rails_admin_uploader/tmpl
#= require rails_admin_uploader/canvas-to-blob
#= require rails_admin_uploader/load-image.all.min.js
#= require rails_admin_uploader/jquery.fileupload
#= require rails_admin_uploader/jquery.fileupload-process
#= require rails_admin_uploader/jquery.fileupload-image
#= require rails_admin_uploader/jquery.fileupload-audio
#= require rails_admin_uploader/jquery.fileupload-video
#= require rails_admin_uploader/jquery.fileupload-validate
#= require rails_admin_uploader/jquery.iframe-transport
#= require rails_admin_uploader/jquery.fileupload-ui

class RaUploader
  constructor: ($t)->
    @$t = $t
    
    @url = @$t.data('url')
    @klass = @$t.data('klass')
    @id = @$t.data('id')
    @field = @$t.data('field')
    @$f = @$t.find('.files')
    @flags = @$t.data('flags')

    @guid = @$t.find('input[type=hidden]').val()

    @$t.disableSelection()

    @initUploader()
    @loadFiles()

  data: ->
    {
      field: @field
      klass: @klass
      id: @id
      guid: @guid
    }

  initSortable: ->
    return false unless @flags.sortable
    @$t.find('.files tbody').sortable
      placeholder: 'attach_item'
      cursor: 'move'
      handle: ".sort-handle",
      update: (event, ui) ->
        $.ajax
          url: url
          type: 'PUT'
          dataType: 'json'
          data: data + '&klass=<%= field.klass %>'

  initUploader: ->
    @$fo = @$t.find('input.fileupload').fileupload(
      url: @url
      dataType: 'json'
      autoUpload: true
      previewMaxWidth: 100
      previewMaxHeight: 100
      formData: (form)=>
        @data()
      uploadTemplateId: "ra_uploader_upload",
      downloadTemplateId: "ra_uploader_download"
      dropZone: @$t
      filesContainer: @$f
      previewCrop: true
      destroy: (e, data) ->
        if e.isDefaultPrevented()
          return false
        that = $(this).data('blueimp-fileupload') or $(this).data('fileupload')

        removeNode = ->
          that._transition(data.context).done ->
            $(this).remove()
            that._trigger 'destroyed', e, data
            return
          return

        data.dataType = data.dataType or that.options.dataType
        $.ajax(data).done(removeNode).fail ->
          that._trigger 'destroyfailed', e, data
          return
    )
    @uploader = @$fo.data('blueimpFileupload')

  loadFiles: ->
    $.ajax
      type: 'GET'
      dataType: 'json'
      url: @url
      data: @data()
      success: (r)=>
        @$f.html("")
        @uploader._renderDownload(r).appendTo(@$f)
        @initSortable()
      error: ->
        @$f.html("Ошибка загрузки списка файлов...").css(color: 'red')

init = ->
  $('.fileupload-block').each ->
    new RaUploader($(this))

upload_template = """
<script id="ra_uploader_upload" type="text/x-tmpl">
{% for (var i=0, file; file=o.files[i]; i++) { %}
  <tr class="template-upload">
    <td></td>
		<td>
      <span class="preview"></span>
    </td>
    <td>
      <div class="fileName">{%=file.name%}</div>
      <div class="fileError"><strong class="error text-danger"></strong></div>
			<div class="fileWeight">{%=o.formatFileSize(file.size)%}</div>
    </td>
    <td>
      <div class="progress progress-striped active" role="progressbar" aria-valuemin="0" aria-valuemax="100" aria-valuenow="0"><div class="progress-bar progress-bar-success" style="width:0%;"></div></div>
    </td>
    <td>
      <button class="btn btn-warning btn-sm cancel">
        <i class="fa fa-ban"></i>
      </button>
    </td>
	</tr>
{% } %}
</script>

"""

download_template = """
<script id="ra_uploader_download" type="text/x-tmpl">
{% for (var i=0, file; file=o.files[i]; i++) { %}
  <tr data-id="{%=file.id%}" class="template-download">
    <td class="sort-handle">
      <i class="fa fa-sort"></i>
    </td>
    <td>
      <a target="_blank" href="{%=file.url%}">
        <img src="{%=file.thumb_url%}" title="{%=file.filename%}" />
      </a>
    </td>
    <td>
      <div class="fileName">
        <a target="_blank" href="{%=file.url%}">{%=file.filename%}</a>
      </div>
      <div class="fileWeight">{%=o.formatFileSize(file.size)%}</div>
      <div class="debug">{%=JSON.stringify(file)%}</div>
      {% if (file.error) { %}
          <div><span class="label label-danger">Ошибка</span> {%=file.error%}</div>
      {% } %}
    </td>
    <td>
      <input value="{%=file.name%}"/></td>
    <td>
      <a class="btn btn-danger btn-sm delete">
        <i class="fa fa-trash-o"></i>
      </a>
    </td>
  </div>
{% } %}
</script>

"""

$(document).on 'pjax:complete', init
$ ->
  $('body').append(upload_template)
  $('body').append(download_template)
  init()

