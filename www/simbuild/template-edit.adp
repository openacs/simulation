<master src="/packages/simulation/www/simulation-master">
  <property name="title">@page_title;noquote@</property>
  <property name="context">@context;noquote@</property>
  <property name="focus">sim_template.pretty_name</property>

<formtemplate id="sim_template"></formtemplate>

<if @workflow_id@ not nil>

  <p>
    <b>&raquo;</b> <a href="@delete_url@" onclick="return confirm('Are you sure you want to delete the template?');">Delete this template</a>
  </p>

  <a name="roles"><h4>Roles</h4></a>

  <include src="/packages/simulation/lib/sim-template-roles" workflow_id="@workflow_id@" display_mode="edit">
  <p></p>

  <a name="tasks"><h4>Tasks</h4></a>

  <include src="/packages/simulation/lib/sim-template-tasks" workflow_id="@workflow_id@" display_mode="edit" >
  
  <p>TODO: Allow reordering of roles, states, tasks.</p>
  <p>TODO: should be only one Add a state button</p>
  <p>TODO: Instead of initialize column and special task, UI should
  show an "initial state" radio button.  The special initialize task should not
  appear in this list.
  <p>
    <b>&raquo;</b> <a href="@spec_url@">Download a specification for this template</a>
  </p>
<if @inst_url@ not nil>
  <p>
    <b>&raquo;</b> <a href="@inst_url@">Start a simulation with this template</a>
  </p>
</if>
</if>
