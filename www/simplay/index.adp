<master src="/packages/simulation/www/simulation-master">
  <property name="title">@title;noquote@</property>
  <property name="context">@context;noquote@</property>

<include src="/packages/simulation/lib/cases" party_id="@user_id@"/>
<p></p>

<if @adminplayer_p@ true>
<h3>Administration</h3>
  <h3>You administer these cases</h3>

  <include src="/packages/simulation/lib/cases-admin"/>
  <p></p>

  <h3>All Messages</h3>

  <include src="/packages/simulation/lib/messages" user_id="@user_id@">
  <p></p>

  <h3>All Tasks</h3>

  <include src="/packages/simulation/lib/tasks" user_id="@user_id@">
  <p></p>

</if>

<p>
  TODO: fix bug with Your tasks count in simulation listing sometimes being too high
</p>
