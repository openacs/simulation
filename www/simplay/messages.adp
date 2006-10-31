<master src="play-master">
  <property name="title">@title;noquote@</property>
  <property name="context">@context;noquote@</property>

<div class="simplay_case_block">
<h3>Inbox</h3>
<include src="/packages/simulation/lib/messages" case_id="@case_id@" role_id="@role_id@" direction="in">
</div>

<div class="simplay_case_block">
<h3>Outbox</h3>
<include src="/packages/simulation/lib/messages" case_id="@case_id@" role_id="@role_id@" direction="out" show_actions_p="0">
</div>

<div>
<a href="@trash_url@">#simulation.Deleted_Messages#</a>
</div>