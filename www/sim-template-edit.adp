<master>
  <property name="title">@page_title;noquote@</property>
  <property name="context">@context;noquote@</property>
  <property name="focus">object.title</property>

<formtemplate id="sim_template"></formtemplate>

<p>
  <b>&raquo;</b> <a href="@delete_url@">Delete this template</a>
</p>

<if @workflow_id@ not nil>
  <h4>Roles</h4>

  <include src="/packages/simulation/lib/sim-template-roles" workflow_id="@workflow_id@" display_mode="edit">

  <h4>Tasks</h4>

  <include src="/packages/simulation/lib/sim-template-tasks" workflow_id="@workflow_id@" display_mode="edit" >
</if>
