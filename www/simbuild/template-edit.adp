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
TODO: Hide task table if there are no states, and show only "add a
  state" link instead
  <p>TODO: B: Allow reordering of roles, states, tasks.</p>
  <p>TODO: Instead of initialize column and special task, UI should
  show an "initial state" radio button.  The special initialize task should not
  appear in this list.
  <p>TODO: B: Better widget for suggested duration.</p>
  <p>TODO: B: When Ready for Use Checkbox is in display (not edit)
  mode, show only the text "yes" or "no" instead of showing a disabled checkbox </p>
  <a class="action">TODO: If !ready_p, display "Mark this template ready for use" link</a>
  <a href="@spec_url@" class="action">Download a specification for this template</a>
  <if @inst_url@ not nil>
    <a href="@inst_url@" class="action">Start a simulation with this template</a>
  </if>
  <a href="@delete_url@" class="action" onclick="return confirm('Are you sure you want to delete the template?');">Delete this template</a>
</if>
