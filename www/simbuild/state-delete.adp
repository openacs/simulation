<master src="/packages/simulation/www/simulation-master">
  <property name="title">@page_title;noquote@</property>
  <property name="context">@context;noquote@</property>

<p><em>@name@</em> #simulation.lt_has_dependent_tasks_s#</p>

<h4>#simulation.Related_Tasks#</h4>
<include src="/packages/simulation/lib/sim-template-tasks" workflow_id=@workflow_id@ package_id=@package_id@>
</if>

<p>
  <b>&raquo;</b> <a href="@delete_url@">#simulation.lt_Delete_name_and_tasks#</a>
</p>

<p>
  <b>&raquo;</b> <a href="@cancel_url@">#simulation.Cancel#</a>
</p>


