<master src="/packages/simulation/www/simulation-master">
  <property name="title">@title;noquote@</property>
  <property name="context">@context;noquote@</property>

<include src="/packages/simulation/lib/cases" party_id="@user_id@"/>
<p></p>

<if @adminplayer_p@ true>

  <h3>All Messages</h3>

  <include src="/packages/simulation/lib/messages" user_id="@user_id@"></include>
  <p></p>

  <h3>All Tasks</h3>

  <include src="/packages/simulation/lib/tasks" user_id="@user_id@"></include>

</if>

<p>TODO: how can a player access completed cases?</p>
