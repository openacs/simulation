<master src="play-master">
  <property name="title">@title;noquote@</property>
  <property name="context">@context;noquote@</property>

<h3>#simulation.Recent_Messages#</h3>

<include src="/packages/simulation/lib/messages"  case_id="@case_id@" role_id="@role_id@" limit="5">

<ul class="action-links">
  <li><a href="@messages_url@">#simulation.All_messages#</a></li>
</ul>

<h3>#simulation.Tasks#</h3>

<include src="/packages/simulation/lib/tasks" case_id="@case_id@" role_id="@role_id@">

<p></p>

<h3>#simulation.Document_Portfolio#</h3>

<include src="/packages/simulation/lib/portfolio" case_id="@case_id@" role_id="@role_id@">

