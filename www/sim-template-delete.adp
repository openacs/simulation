<master>
  <property name="title">@page_title;noquote@</property>
  <property name="context">@context;noquote@</property>

<p>
  You are about to delete template "@template_name@". Please review the contents of the template below before you proceed.
</p>

<h4>Roles</h4>

<include src="/packages/simulation/lib/sim-template-roles" workflow_id=@workflow_id@ package_id=@package_id@>

<h4>Tasks</h4>

<include src="/packages/simulation/lib/sim-template-tasks" workflow_id="@workflow_id@" package_id="@package_id@" display_mode="edit" >
