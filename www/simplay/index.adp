<master src="/packages/simulation/www/simulation-master">
  <property name="title">@title;noquote@</property>
  <property name="context">@context;noquote@</property>

<if @case_id@ not nil>
    TODO: show list of valid cases
</if>
<else>
     <include src="/packages/simulation/lib/messages" user_id="@user_id@" case_id="@case_id@"></include>
     <include src="/packages/simulation/lib/tasks" user_id="@user_id@" case_id="@case_id@"></include>
</else>

<if @adminplayer_p@>
    TODO: in playeradmin, show all tasks.  (Still segregate messages by case?)
</if>
<pre>  
TODO: playeradmin mode shows all cases; player mode shows one case

in player mode, show "desk" - ie, list of messages and list of tasks,
plus links to archive

TODO: how can a player access completed cases?

</pre>