<master src="/packages/simulation/www/simulation-master">
  <property name="title">@page_title;noquote@</property>
  <property name="context">@context;noquote@</property>
  <property name="focus">sim_template.pretty_name</property>

<formtemplate id="sim_template"></formtemplate>

<if @workflow_id@ not nil>

  <a name="roles"><h4>Roles</h4></a>

  <include src="/packages/simulation/lib/sim-template-roles" workflow_id="@workflow_id@" display_mode="edit">
  <p></p>

  <a name="tasks"><h4>Tasks</h4></a>

  <include src="/packages/simulation/lib/sim-template-tasks" workflow_id="@workflow_id@" display_mode="edit" >
  
<p>
  <p>TODO: B: Allow reordering of roles, tasks, states.</p>

  <a href="@spec_url@" class="action">Download a specification for this template</a>

  <if @mark_ready_url@ not nil>
    <a href="@mark_ready_url@" class="action">Mark this template ready for use</a>
  </if>

  <if @inst_url@ not nil>
    <a href="@inst_url@" class="action">Start a simulation with this template</a>
  </if>

  <a href="@delete_url@" class="action" onclick="return confirm('Are you sure you want to delete the template?');">Delete this template</a>

</if>
