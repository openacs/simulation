<master src="/packages/simulation/www/simulation-master">
  <property name="title">@page_title;noquote@</property>
  <property name="context">@context;noquote@</property>
  <property name="header_stuff">
    <script language="javascript">
        function FormRefresh(form_name) {
            if (document.forms == null) return;
            if (document.forms[form_name] == null) return;
            if (document.forms[form_name].elements["__refreshing_p"] == null) return;

            document.forms[form_name].elements["__refreshing_p"].value = 1;
            document.forms[form_name].submit();
        }
    </script>
  </property>

<div id="tabs-div">
  <div id="tabs-container">
    <div id="tabs">
      <multiple name="wizard">
        <if "@wizard.id@" eq "@wizard:current_id@">
          <div class="tab" id="tabs-here">
            @wizard.id@. @wizard.label@
          </div>
        </if>
        <else>
          <div class="tab">
            @wizard.id@. <a href="<%=[template::wizard get_forward_url @wizard.id@]%>">@wizard.label@</a>
          </div>
        </else>
      </multiple>
    </div>
  </div>
</div>
<div id="tabs-body">

  <h2>@sub_title@</h2>

  <include src="@wizard:current_url@">

  <div style="clear: both;"></div>
</div>
