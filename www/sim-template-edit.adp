<master>
  <property name="title">@page_title;noquote@</property>
  <property name="context">@context;noquote@</property>
  <property name="focus">object.title</property>

<formtemplate id="sim_template"></formtemplate>

<if @mode@ eq edit>
<h4>Associated Sim Objects</h4>
<p><listtemplate name="sim_objects"></listtemplate></p>
<p><a href="sim-template-add-objects?workflow_id=@workflow_id@">Add Sim
Objects to this Workflow</a>
<h4>Roles</h4>
<p><listtemplate name="roles"></listtemplate></p>
<p><a href="role-edit?workflow_id=@workflow_id@">Add a role</a>
<h4>Tasks</h4>
</if>