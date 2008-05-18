<master src="/packages/simulation/www/simulation-master">
  <property name="title">@page_title;noquote@</property>
  <property name="context">@context;noquote@</property>
  <property name="header_stuff">
    <script language="javascript">
    </script>
  </property>

<div id="main-navigation">
  <ul>
    <multiple name="wizard">
      <if "@wizard.id@" eq "@wizard:current_id@">
        <li id="main-navigation-active">
           @wizard.id@. @wizard.label@
           <if @wizard.complete_p@><img src="/resources/acs-subsite/checkboxchecked.gif"></if>
        </li>
      </if>
      <else>
        <if @wizard.id@ ge @lowest_available@ and @wizard.id@ le @highest_available@>
          <li>
            @wizard.id@. <a href="<%=[template::wizard get_forward_url @wizard.id@]%>">@wizard.label@</a>
            <if @wizard.complete_p@><img src="/resources/acs-subsite/checkboxchecked.gif"></if>
          </li>
        </if>
        <else>
          <li>
            @wizard.id@. @wizard.label@
            <if @wizard.complete_p@><img src="/resources/acs-subsite/checkboxchecked.gif"></if>
          </li>
        </else>
      </else>
    </multiple>
  
  </ul>
</div>

<div style="clear: both;"></div>
<h2>@sub_title@</h2>

<include src="@wizard:current_url@">

<div style="clear: both;"></div>
