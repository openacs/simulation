<master src="play-master">
  <property name="title">@title;noquote@</property>
  <property name="context">@context;noquote@</property>

<h3>Recent Messages</h3>

<include src="/packages/simulation/lib/messages"  user_id="@user_id@" case_id="@case_id@" role_id="@role_id@" limit="5">

<ul class="action-links">
  <li><a href="@messages_url@">All messages...</a></li>
</ul>

<h3>Tasks</h3>

<include src="/packages/simulation/lib/tasks" user_id="@user_id@" case_id="@case_id@" role_id="@role_id@">

<p></p>

<h3>Document Portfolio</h3>

<include src="/packages/simulation/lib/portfolio" case_id="@case_id@" role_id="@role_id@">
