<master src="play-master">
  <property name="title">@title;noquote@</property>
  <property name="context">@context;noquote@</property>

<div class="simplay_case_messages">
<h3>Recent Messages</h3>
<include src="/packages/simulation/lib/messages" case_id="@case_id@" role_id="@role_id@" limit="5">
</div>

<div class="simplay_case_action-links">
<ul class="action-links">
  <li><a href="@messages_url@">All messages...</a></li>
</ul>
</div>

<div class="simplay_case_tasks">
<h3>Tasks</h3>
<include src="/packages/simulation/lib/tasks" case_id="@case_id@" role_id="@role_id@">
</div>
<p></p>

<div class="simplay_case_portfolio">
<h3>Document Portfolio</h3>
<include src="/packages/simulation/lib/portfolio" case_id="@case_id@" role_id="@role_id@">
</div>
