<!DOCTYPE html>
<!--[if lt IE 7]>
  <html lang="ru" class="no-js ie6 oldie">
  
  </html>
<![endif]-->
<!--[if IE 7]>
  <html lang="ru" class="no-js ie7 oldie">
  
  </html>
<![endif]-->
<!--[if IE 8]>
  <html lang="ru" class="no-js ie8 oldie">
  
  </html>
<![endif]-->
<!-- [if gt IE 8] <!-->
<html lang="ru" class="no-js">
  <!-- <![endif]-->
  
  <head>
    <title>Редактор форм</title>
    <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1">
    <meta name="description" content="Description">
    <meta name="author" content="lexich">
    <meta name="HandheldFriendly" content="True">
    <meta name="MobileOptimized" content="320">
    <meta http-equiv="content-type" content="text/html; charset=utf8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="CSRFToken" content="${csrfValue()}">
    <link href="/resources//build/style-form-builder-0.0.3.min.css" rel="stylesheet"
    media="screen">
    <!--[if lt IE 7]>
      <link href="/resources//build/style-form-builder-0.0.3.ie7.min.css" rel="stylesheet"
      media="screen">
    <![endif]-->
  </head>
  
  <body>
    <script type="text/javascript">
      rootformconfig={};
        rootformconfig.url = "/forms.json";
 rootformconfig.param = "guid";
    </script>
    <div class="body container-fluid">
      <div class="row-fluid">
        <div class="span8" data-html-form></div>
        <div class="span4 ui_settings_editor fuelux">
          <form class="ui_settings_editor__area" data-html-settings>
            <fieldset>
              <legend>Настройки элемента</legend>
              <div data-html-settings-loader></div>
              <div class="form-actions" data-html-settings-item> <a href="javascript:void(0);" data-js-save class="btn btn-primary">Применить</a>

                <!--a
                href="javascript:void(0);" data-js-remove class="btn btn-danger">Удалить</a--> <a href="javascript:void(0);" data-js-hide class="btn">Закрыть</a>

              </div>
            </fieldset>
          </form>
        </div>
      </div>
    </div>
    <div class="navbar navbar-inverse navbar-fixed-top navbar-fixed-top-back">
      <div class="navbar-inner">
        <div class="container">
          <div class="nav-collapse collapse"> <a class="brand icon-save" href="javascript:void(0);" data-js-global-form-save
            title="Сохранить"></a>

            <ul class="nav">
              <li class="active"> <a href="#input" data-toggle="tab">Input</a>

              </li>
              <li> <a href="#js" data-toggle="tab">Dynamic</a>

              </li>
              <li> <a data-toggle="tab" href="#notvisual">Not Visual</a>

              </li>
            </ul>
          </div>
        </div>
      </div>
      <div class="tab-content ui_tools navbar-inner">
        <div id="input" class="tab-pane active ui_tools__container">
          <ul>
            <li>
              <script type="text/template" data-ui-jsrender="{&quot;title&quot;:&quot;Пароль&quot;,&quot;label&quot;:&quot;password&quot;,&quot;placeholder&quot;:&quot;password&quot;,&quot;name&quot;:&quot;password&quot;,&quot;type&quot;:{&quot;value&quot;:&quot;password&quot;,&quot;type&quot;:&quot;hidden&quot;},&quot;help&quot;:&quot;help&quot;,&quot;position&quot;:{&quot;value&quot;:0,&quot;type&quot;:&quot;hidden&quot;},&quot;row&quot;:{&quot;value&quot;:0,&quot;type&quot;:&quot;hidden&quot;}}"
              data-ui-jsrender-type="password">
                <div class="control-group">
                  <label class="control-label" for="<%= id %>"><%= label %></label>
                  <div class="controls">
                    <input type="password" id="<%= id %>" name="<%= name %>" placeholder="<%= placeholder %>">
                    <p class="help-block valtype" data-valtype="help"><%= help %></p>
                  </div>
                </div>
              </script>
            </li>
            <li>
              <script type="text/template" data-ui-jsrender="{&quot;title&quot;:&quot;Поле ввода&quot;,&quot;label&quot;:&quot;Label for textarea&quot;,&quot;placeholder&quot;:&quot;Placeholder for textarea&quot;,&quot;name&quot;:&quot;textarea&quot;,&quot;help&quot;:&quot;Textarea help&quot;,&quot;type&quot;:{&quot;value&quot;:&quot;textarea&quot;,&quot;type&quot;:&quot;hidden&quot;}}"
              data-ui-jsrender-type="textarea">
                <div class="control-group">
                  <label class="control-label" for="<%= id %>"><%= label %></label>
                  <div class="controls">
                    <textarea rows="3" id="<%= id %>" name="<%= name %>" placeholder="<%= placeholder %>"></textarea>
                    <p class="help-block valtype" data-valtype="help"><%= help %></p>
                  </div>
                </div>
              </script>
            </li>
            <li>
              <script type="text/template" data-ui-jsrender="{&quot;title&quot;:&quot;Поле ввода&quot;,&quot;label&quot;:&quot;input&quot;,&quot;placeholder&quot;:&quot;input&quot;,&quot;name&quot;:&quot;input&quot;,&quot;help&quot;:&quot;help&quot;,&quot;type&quot;:{&quot;value&quot;:&quot;input&quot;,&quot;type&quot;:&quot;hidden&quot;},&quot;position&quot;:{&quot;value&quot;:0,&quot;type&quot;:&quot;hidden&quot;},&quot;row&quot;:{&quot;value&quot;:0,&quot;type&quot;:&quot;hidden&quot;}}"
              data-ui-jsrender-type="input">
                <div class="control-group">
                  <label class="control-label" for="<%= id %>"><%= label %></label>
                  <div class="controls">
                    <input type="text" id="<%= id %>" name="<%= name %>" placeholder="<%= placeholder %>">
                    <% if (help) { %>
                      <p class="help-block valtype" data-valtype="help"><%= help %></p>
                    <% } %>
                  </div>
                </div>
              </script>
            </li>
            <li>
              <script type="text/template" data-ui-jsrender="{&quot;title&quot;:&quot;Фаил&quot;,&quot;label&quot;:&quot;file&quot;,&quot;placeholder&quot;:&quot;file&quot;,&quot;name&quot;:&quot;file&quot;,&quot;help&quot;:&quot;help&quot;,&quot;type&quot;:{&quot;value&quot;:&quot;file&quot;,&quot;type&quot;:&quot;hidden&quot;},&quot;position&quot;:{&quot;value&quot;:0,&quot;type&quot;:&quot;hidden&quot;},&quot;row&quot;:{&quot;value&quot;:0,&quot;type&quot;:&quot;hidden&quot;}}"
              data-ui-jsrender-type="file">
                <div class="control-group">
                  <label class="control-label" for="<%= id %>"><%= label %></label>
                  <div class="controls">
                    <input type="file" id="<%= id %>" name="<%= name %>" placeholder="<%= placeholder %>">
                    <p class="help-block valtype" data-valtype="help"><%= help %></p>
                  </div>
                </div>
              </script>
            </li>
          </ul>
        </div>
        <div id="js" class="tab-pane ui_tools__container">
          <ul>
            <li>
              <script type="text/template" data-ui-jsrender="{&quot;title&quot;:&quot;Элемент выбора&quot;,&quot;label&quot;:&quot;Label for select2&quot;,&quot;placeholder&quot;:&quot;Placeholder for select2&quot;,&quot;name&quot;:&quot;select2&quot;,&quot;help&quot;:&quot;Help select2&quot;,&quot;position&quot;:{&quot;value&quot;:0,&quot;type&quot;:&quot;hidden&quot;},&quot;row&quot;:{&quot;value&quot;:0,&quot;type&quot;:&quot;hidden&quot;},&quot;type&quot;:{&quot;value&quot;:&quot;select2&quot;,&quot;type&quot;:&quot;hidden&quot;},&quot;url&quot;:&quot;/select2.json&quot;,&quot;more&quot;:&quot;20&quot;}"
              data-ui-jsrender-type="select2">
                <div class="control-group">
                  <label class="control-label" for="<%= id %>"><%= label %></label>
                  <div class="controls" placeholder="<%= placeholder %>">
                    <input name="<%= name %>" id="<%= id %>"
                      data-js-url="<%= url %>" 
                      data-js-more="<%= more %>"
                      data-js-placeholder="<%= placeholder %>" />
                    <p class="help-block valtype" data-valtype="help"><%= help %></p>
                  </div>
                </div>
              </script>
            </li>
            <li>
              <script type="text/template" data-ui-jsrender="{&quot;title&quot;:&quot;Дата&quot;,&quot;label&quot;:&quot;datepicker&quot;,&quot;placeholder&quot;:&quot;datepicker&quot;,&quot;name&quot;:&quot;datepicker&quot;,&quot;help&quot;:&quot;help&quot;,&quot;type&quot;:{&quot;value&quot;:&quot;datepicker&quot;,&quot;type&quot;:&quot;hidden&quot;},&quot;format&quot;:&quot;dd-mm-yyyy&quot;,&quot;value&quot;:&quot;12-02-2013&quot;,&quot;position&quot;:{&quot;value&quot;:0,&quot;type&quot;:&quot;hidden&quot;},&quot;row&quot;:{&quot;value&quot;:0,&quot;type&quot;:&quot;hidden&quot;}}"
              data-ui-jsrender-type="datepicker">
                <div class="control-group">
                    <label class="control-label" for="<%= id %>"><%= label %></label>
                    <div class="controls">
                        <div class="input-append date" id="dp3" >
                            <input id="<%= id %>" size="16" type="text" value="<%= value %>" data-date-format="<%= format %>">
                            <span class="add-on"><i class="icon-th"></i></span>
                        </div>
                        <p class="help-block valtype" data-valtype="help"><%= help %></p>
                    </div>
                </div>
              </script>
            </li>
            <li>
              <script type="text/template" data-ui-jsrender="{&quot;title&quot;:&quot;Флажек&quot;,&quot;label&quot;:&quot;checkbox&quot;,&quot;placeholder&quot;:&quot;checkbox&quot;,&quot;name&quot;:&quot;checkbox&quot;,&quot;help&quot;:&quot;help&quot;,&quot;type&quot;:{&quot;value&quot;:&quot;checkbox&quot;,&quot;type&quot;:&quot;hidden&quot;},&quot;position&quot;:{&quot;value&quot;:0,&quot;type&quot;:&quot;hidden&quot;},&quot;row&quot;:{&quot;value&quot;:0,&quot;type&quot;:&quot;hidden&quot;}}"
              data-ui-jsrender-type="checkbox">
                <div class="control-group">
                  <div class="controls">
                    <label class="checkbox checkbox-custom" for="<%= id %>">
                      <input id="<%= id %>" type="checkbox"/>
                      <%= label %></label>
                    <p class="help-block valtype" data-valtype="help"><%= help %></p>
                  </div>
                </div>
              </script>
            </li>
          </ul>
        </div>
        <div id="notvisual" class="tab-pane ui_tools__container">
          <ul>
            <li>
              <script type="text/template" data-ui-jsrender="{&quot;title&quot;:&quot;Привязка&quot;,&quot;name&quot;:&quot;binder&quot;,&quot;notvisual&quot;:&quot;1&quot;,&quot;source&quot;:&quot;source&quot;,&quot;target&quot;:&quot;target&quot;,&quot;type&quot;:{&quot;value&quot;:&quot;binder&quot;,&quot;type&quot;:&quot;hidden&quot;}}"
              data-ui-jsrender-type="binder">
                <div class="ui_tools-binder">
                    <div class="ui_tools__item">
                        <p><%= name %></p>
                    </div>
                </div>
                <object data-binder='{"source":"<%= source %>","target":"<%= target %>"' width="0" height="0"></object>
              </script>
            </li>
          </ul>
        </div>
      </div>
    </div>
    <div style="display:none">
      <script data-ui-jsrender-modal-template="input" type="text/template">
        <label for="__id_label">Название</label>
        <input id="__id_label" type="text" name="label" value="Comment">
    
        <label for="__id_placeholder">placeholder</label>
        <input id="__id_placeholder" type="text" name="placeholder" value="Your comment">
    
        <label for="__id_name">name</label>
        <input id="__id_name" type="text" name="name" value="comment">
    
        <label for="__id_type">type</label>
        <select name="" id="" data-ui="select2">
            <option>One</option>
            <option>Two</option>
            <option>Three</option>
        </select>
        <label for="MySpinner">Spinner</label>
        <div id="MySpinner" class="spinner row-fluid" data-type="spinner">
            <input type="text" class="input-mini spinner-input" />
            <div class="spinner-buttons	btn-group btn-group-vertical">
                <a href="javascript:void(0)" class="btn spinner-up"><i class="icon-chevron-up"></i></a>
                <a href="javascript:void(0)" class="btn spinner-down"><i class="icon-chevron-down"></i></a>
            </div>
        </div>
      </script>
      <script data-ui-jsrender-modal-template="binder" type="text/template">
        <label for="__id_name">Название</label>
        <input id="__id_name" type="text" name="name">
    
        <label for="__id_source">Источник</label>
        <select name="source" id="__id_source" data-ui="select2" data-ui-data='{"inject":{"data":"loadIds"}}' />
    
        <label for="__id_target">Приемник</label>
        <select name="target" id="__id_target" data-ui="select2" data-ui-data='{"inject":{"data":"loadIds"}}' />
      </script>
    </div>
    <div class="ui_notvisual navbar-fixed-bottom" data-html-notvisual></div>
    <script type="text/template" id="FormViewTemplate">
      <form data-html-formloader></form>
      <div data-drop-accept-placeholder="form" class="ui_global_placeholder row-fluid form-horizontal"></div>
    </script>
    <script type="text/template" id="FieldsetViewTemplate">
      <legend contenteditable data-bind="title" class="ui_fieldset__legend" ><%= title %></legend>
      <div data-html-fieldset-loader class="ui_fieldset__loader"></div>
      <div data-drop-accept-placeholder="fieldset" class="ui_global_placeholder row-fluid"></div>
      <span class="icon-resize-vertical ui_fieldset__direction" data-js-fieldset-position></span>
    </script>
    <script type="text/template" id="RowViewTemplate">
      <div data-drop-accept-placeholder="row" data-ghost-row class="ui_row__prev_loader row-fluid ui_global_placeholder"></div>
      <div data-drop-accept class="ui_row__loader row-fluid"></div>
    </script>
    <script type="text/template" id="FormItemViewTemplate">
      <div class="ui_formitem__tools clearfix">
          <span data-js-formitem-move class='icon-move ui_formitem__move'/>
          <span data-js-formitem-incsize class="icon-plus ui_formitem__plus" ></span>
          <span data-js-formitem-decsize class="icon-minus ui_formitem__minus" ></span>
          <span data-js-formitem-remove class="icon-remove ui_formitem__remove" ></span>
      </div>
      <%= content %>
    </script>
    <script id="NotVisualViewTemplate" type="text/template">
      <div class="row-fluid ui_notvisual__container navbar-inner" data-js-notvisual-drop=""></div>
    </script>
    <script id="NotVisualItemTemplate" type="text/template">
      <%= content %>
    </script>
    <script type="text/template" id="ToolItemViewTemplate">
      <div class="ui_tools__item">
        <% if(title!=""){ %>
           <p><%= title.charAt(0).toUpperCase() + title.slice(1) %></p>
        <% } %>
      </div>
    </script>
    <script type="text/template" id="modalTemplate">
      <div class="modal">
       <div class="modal-header">
         <button type="button" data-js-close class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
         <h3>Settings</h3>
       </div>
       <div class="modal-body"></div>
       <div class="modal-footer">
         <a href="#" data-js-close class="btn">Close</a>
         <a href="#" data-js-save class="btn btn-primary">Save changes</a>
       </div>
      </div>
    </script>
    <script type="text/template" data-modal-type="input">
      <label for="__id_<%= name %>"><%= name %></label>
      <input id="__id_<%= name %>" type="text" name="<%= name %>" value="<%= value %>" data-type="">
    </script>
    <script type="text/template" data-modal-type="select">
      <label for="__id_<%= name %>"><%= name %></label>
      <select id="__id_<%= name %>" name="<%= name %>" value="<%= value %>" data-type="">
      <% _.each(data,function(item){ %>
        <option value="<%= item %>" <% if(value==item){ %>selected="selected"<% } %>  ><%= item %></option>
      <%});%>
      </select>
    </script>
    <script src="/resources//js/common/base.js"></script>
    <script src="/resources//js/requirejs/require.js">
</script>
    <script src="/resources//js/config.js"></script>
    <script src="/resources//build/main-form-builder-0.0.3.js"></script>
  </body>

</html>