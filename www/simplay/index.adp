<master src="/packages/simulation/www/simulation-master">
  <property name="title">@title;noquote@</property>
  <property name="context">@context;noquote@</property>

Show list of cases and make user pick one before proceeding.  However, if there is only one valid case, use it.
<include src="/packages/simulation/lib/cases" party_id="@user_id@"/>

<if @adminplayer_p@>
     <include src="/packages/simulation/lib/messages" user_id="@user_id@"></include>
<p>
     <include src="/packages/simulation/lib/tasks" user_id="@user_id@"></include>
</if>
<p>TODO: how can a player access completed cases?
