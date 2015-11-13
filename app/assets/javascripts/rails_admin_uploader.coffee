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

upload_template = """
<script id="ra_uploader_upload" type="text/x-tmpl">
{% for (var i=0, file; file=o.files[i]; i++) { %}
  <tr class="template-upload">
    {% if (o.options.flags.sortable) { %}
      <td></td>
    {% } %}
    {% if (o.options.flags.enableable) { %}
      <td></td>
    {% } %}
		<td width="200">
      <span class="preview"></span>
    </td>
    <td width="200">
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

e_spin = '<a class="label label-primary">
  <i class="fa fa-spinner fa-spin"></i>
</a>'
e_on = '<a class="label label-success">
  <i class="fa fa-check"></i>
</a>'
e_off = '<a class="label label-danger">
  <i class="fa fa-times"></i>
</a>'

download_template = """
<script id="ra_uploader_download" type="text/x-tmpl">
{% for (var i=0, file; file=o.files[i]; i++) { %}
  <tr data-id="{%=file.id%}" class="template-download">
    {% if (o.options.flags.sortable) { %}
      <td class="sort-handle">
        <i class="fa fa-sort"></i>
      </td>
    {% } %}
    {%= JSON.stringify(o) %}
    {% if (o.options.flags.enableable) { %}
      <td class="enable-button">
        {% if (file.enabled) { %}
          #{e_on}
        {% } else { %}
          #{e_off}
        {% } %}
      </td>
    {% } %}
    <td width="200">
      <a target="_blank" href="{%=file.url%}">
        <img src="{%=file.thumb_url%}" title="{%=file.filename%}" />
      </a>
    </td>
    <td width="200">
      <div class="fileName">
        <a target="_blank" href="{%=file.url%}">{%=file.filename%}</a>
      </div>
      <div class="fileWeight">{%=o.formatFileSize(file.size)%}</div>
      {% if (file.error) { %}
          <div><span class="label label-danger">Ошибка</span> {%=file.error%}</div>
      {% } %}
    </td>
    <td>
      {% if (o.options.flags.nameable) { %}
        <input class="nameable" value="{%=file.name%}" placeholder="Название"/>
        <i class="spinner fa fa-spinner fa-spin" style="display: none;"></i>
      {% } %}
    <td>
      <a class="btn btn-danger btn-sm delete">
        <i class="fa fa-trash-o"></i>
      </a>
    </td>
  </div>
{% } %}
</script>

"""

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

  data: =>
    r = {
      field: @field
      klass: @klass
      guid: @guid
    }
    if @id
      r.obj_id = @id
    r

  initSortable: ->
    return false unless @flags.sortable
    @$t.find('.files tbody').sortable
      placeholder: 'attach_item'
      cursor: 'move'
      handle: ".sort-handle",
      update: (event, ui) =>
        order = []
        @$t.find('.template-download').each ->
          $i = $(this)
          order.push($i.data('id'))
        d = @data()
        d.order = order
        $.ajax
          url: @url
          type: 'POST'
          dataType: 'json'
          data: d
          error: (r)->
            alert(r)

  initEnableable: =>
    return false unless @flags.enableable
    t = @
    @$t.on('click', '.enable-button a', (e)->
      $t = $(this)
      $i = $t.parents('.template-download')
      e.preventDefault()
      d = t.data()
      d.img = {enabled: !$t.hasClass('label-success')}
      $p = $t.parent()
      $p.html(e_spin)
      id = $i.data('id')
      $.ajax
        url: "#{t.url}/#{id}"
        type: 'PUT'
        dataType: 'json'
        data: d
        success: (r)->
          $p.html(if r.enabled then e_on else e_off)
        error: (r)->
          alert(r)
    )

  initNameable: =>
    return false unless @flags.nameable
    t = @
    @$t.on('blur', 'input.nameable', (e)->
      $t = $(this)
      $i = $t.parents('.template-download')
      e.preventDefault()
      d = t.data()
      d.img = {name: $t.val()}
      id = $i.data('id')
      $t.next('.spinner').show()
      $.ajax
        url: "#{t.url}/#{id}"
        type: 'PUT'
        dataType: 'json'
        data: d
        success: (r)->
          $t.next('.spinner').hide()
        error: (r)->
          alert(r)
    )

  initUploader: =>
    t = @
    @$fo = @$t.find('input.fileupload').fileupload(
      url: @url
      dataType: 'json'
      autoUpload: true
      previewMaxWidth: 100
      previewMaxHeight: 100
      formData: (form)=>
        formData = []
        $.each @data(), (name, value) ->
          formData.push
            name: name
            value: value
        formData
      uploadTemplateId: "ra_uploader_upload",
      downloadTemplateId: "ra_uploader_download"
      dropZone: @$t
      filesContainer: @$f
      previewCrop: true
      flags: @flags
      destroy: (e, data) ->
        $i = data.context
        d = t.data()
        id = $i.data('id')
        if confirm("Точно удалить?")
          $.ajax
            url: "#{t.url}/#{id}"
            type: 'DELETE'
            dataType: 'json'
            data: d
            success: (r)->
              $i.remove()
            error: (r)->
              alert(r)
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
        @uploader._renderDownload(r.files).appendTo(@$f)
        @initSortable()
        @initEnableable()
        @initNameable()
      error: ->
        @$f.html("Ошибка загрузки списка файлов...").css(color: 'red')

init = ->
  $('.fileupload-block').each ->
    new RaUploader($(this))


$(document).on 'pjax:complete', init
$ ->
  $('body').append(upload_template)
  $('body').append(download_template)
  init()

