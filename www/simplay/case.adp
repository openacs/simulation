<master src="play-master">
  <property name="title">@title;noquote@</property>
  <property name="context">@context;noquote@</property>

<h3>Tasks</h3>

<include src="/packages/simulation/lib/tasks" user_id="@user_id@" case_id="@case_id@"></include>
<p></p>

<h3>Messages</h3>

<include src="/packages/simulation/lib/messages"  user_id="@user_id@" case_id="@case_id@"></include>
<p></p>

<h3>Portfolio</h3>

<include src="/packages/simulation/lib/portfolio" case_id="@case_id@"></include>
