<master src="/packages/simulation/www/simulation-master">
  <property name="title">@title;noquote@</property>
  <property name="context">@context;noquote@</property>

<include src="/packages/simulation/lib/cases" party_id="@user_id@"/>
<p></p>

<if @adminplayer_p@ true>
<h3>#simulation.Administration#</h3>
  <h3>#simulation.lt_You_administer_these#</h3>

  <include src="/packages/simulation/lib/cases-admin"/>
  <p></p>

  <h3>#simulation.All_Messages#</h3>

  <include src="/packages/simulation/lib/messages" user_id="@user_id@">
  <p></p>

  <h3>#simulation.Your_Tasks#</h3>

  <include src="/packages/simulation/lib/simulations-task-count">
  <p>
  </p>

</if>

