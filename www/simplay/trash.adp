<master src="play-master">
  <property name="title">@title;noquote@</property>
  <property name="context">@context;noquote@</property>

<div class="simplay_case_block">
<include src="/packages/simulation/lib/messages" case_id="@case_id@" role_id="@role_id@"  deleted_p="1" show_actions_p="0">
</div>

<div>
<a href="@inbox_url@">#simulation.back_to_messages#</a>
</div>