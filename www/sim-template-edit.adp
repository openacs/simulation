<master>
  <property name="title">@page_title;noquote@</property>
  <property name="context">@context;noquote@</property>
  <property name="focus">object.title</property>

<formtemplate id="sim_template"></formtemplate>

<if @workflow_id@ not nil>
<h4>Associated Sim Objects</h4>
<include src="/packages/simulation/lib/sim-template-objects" workflow_id=@workflow_id@ package_id=@package_id@>
<h4>Roles</h4>
<include src="/packages/simulation/lib/sim-template-roles" workflow_id=@workflow_id@ package_id=@package_id@>
<h4>Tasks</h4>
<include src="/packages/simulation/lib/sim-template-tasks" workflow_id="@workflow_id@" package_id="@package_id@" usage_mode="edit" >
</if>