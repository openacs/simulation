<master src="play-master">
  <property name="title">@title;noquote@</property>
  <property name="context">@context;noquote@</property>
  <property name="workflow_id">@workflow_id;noquote@</property>

<div class="simplay_case_block">

  <h3>#simulation.Recent_Messages#</h3>
  <include src="/packages/simulation/lib/messages" case_id="@case_id@" role_id="@role_id@" limit="5">

  <div class="simplay_case_action-links">
    <ul class="action-links">
      <li><a href="@messages_url@">#simulation.All_messages#</a></li>
    </ul>
  </div>

</div>

<div class="simplay_case_block">
<h3>#simulation.Tasks#</h3>
<include src="/packages/simulation/lib/tasks" case_id="@case_id@" role_id="@role_id@">
</div>

<div class="simplay_case_block">
<h3>#simulation.Document_Portfolio#</h3>
<if @portfolio_orderby@ >
<include src="/packages/simulation/lib/portfolio" case_id="@case_id@" role_id="@role_id@" portfolio_orderby="@portfolio_orderby@">
</if>
<else>
<include src="/packages/simulation/lib/portfolio" case_id="@case_id@" role_id="@role_id@">
</else>
</div>
