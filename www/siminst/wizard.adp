<master src="/packages/simulation/www/simulation-master">
  <property name="title">@page_title;noquote@</property>
  <property name="context">@context;noquote@</property>
  <property name="header_stuff">
    <script language="javascript">
    </script>
  </property>

<div id="tabs-div">
  <div id="tabs-container">
    <div id="tabs">
      <multiple name="wizard">
        <if "@wizard.id@" eq "@wizard:current_id@">
          <div class="tab" id="tabs-here">
            @wizard.id@. @wizard.label@
            <if @wizard.id@ le @progress@><img src="/resources/acs-subsite/checkboxchecked.gif"></if>
          </div>
        </if>
        <else>
          <if @wizard.id@ ge @lowest_available@ and @wizard.id@ le @highest_available@>
            <div class="tab">
              @wizard.id@. <a href="<%=[template::wizard get_forward_url @wizard.id@]%>">@wizard.label@</a>
              <if @wizard.id@ le @progress@><img src="/resources/acs-subsite/checkboxchecked.gif"></if>
            </div>
          </if>
          <else>
            <div class="tab disabled">
              @wizard.id@. @wizard.label@
              <if @wizard.id@ le @progress@><img src="/resources/acs-subsite/checkboxchecked.gif"></if>
            </div>
          </else>
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
<p>TODO: put a warning next to the finish button for any incomplete
requirements, using the same tests we use to determine if tabs are
complete.  Should include:
<ul>
<li>missing attachments (link to tab 2)
<li>missing dates (link to tab 3)
<li>groups that aren't cast to any roles (link to tab 6)
</ul>