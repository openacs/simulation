<master src="/packages/simulation/www/simulation-master">
  <property name="title">@title;noquote@</property>
  <property name="context">@context;noquote@</property>

<div class="help-link"><a href="@help_url@">#simulation.SimPlay_Help#</a></div>

<div class="simplay_index_cases">
  <h3>#simulation.lt_Cases_in_which_you_ar#</h3>
  <include src="/packages/simulation/lib/cases" party_id="@user_id@"/>
</div>

<if @adminplayer_p@ true>
  <h3>#simulation.Administration#</h3>

  <div class="simplay_index_cases_admin">
    <h3>#simulation.Cases#</h3>
    <if @case_admin_order@>			
    <include src="/packages/simulation/lib/cases-admin" case_admin_order="@case_admin_order@" />
    </if>
    <else>
    <include src="/packages/simulation/lib/cases-admin"/>
    </else>
  </div>

  <div class="simplay_index_messages">
    <h3>#simulation.All_Messages#</h3>
    <include src="/packages/simulation/lib/messages" user_id="@user_id@">
  </div>

</if>

<div class="simplay_case-admin_action-links">
  <ul class="action-links">
    <li><a href="@package_uri@">#simulation.lt_Return_to_Simulation__1#</a></li>
  </ul>
</div>