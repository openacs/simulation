<master src="/packages/simulation/www/simulation-master">
  <property name="title">@title;noquote@</property>
  <property name="context">@context;noquote@</property>

<div class="simplay_index_cases">
  <include src="/packages/simulation/lib/cases" party_id="@user_id@"/>
</div>

<if @adminplayer_p@ true>
  <h3>#simulation.Administration#</h3>

  <div class="simplay_index_cases_admin">
    <h3>#simulation.lt_You_administer_these#</h3>
    <include src="/packages/simulation/lib/cases-admin"/>
  </div>

  <div class="simplay_index_messages">
    <h3>#simulation.All_Messages#</h3>
    <include src="/packages/simulation/lib/messages" user_id="@user_id@">
  </div>

  <div class="simplay_index_tasks">
    <h3>#simulation.Your_Tasks#</h3>
    <include src="/packages/simulation/lib/simulations-task-count">
  </div>

</if>

