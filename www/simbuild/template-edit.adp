<master src="/packages/simulation/www/simulation-master">
  <property name="title">@page_title;noquote@</property>
  <property name="context">@context;noquote@</property>
  <property name="focus">sim_template.pretty_name</property>

<if @workflow_id@ nil>
  <!-- Creating -->
  <formtemplate id="sim_template"></formtemplate>
</if>
<else>
  <!-- Editing -->
  <table width="100%">
    <tr>
      <td valign="top">
        <div class="portlet">
          <h2>Template</h2>
          <div class="portlet-body">
            <formtemplate id="sim_template"></formtemplate>
              <a href="@spec_url@" class="action">Download a specification for this template</a>

              <if @mark_ready_url@ not nil>
                <a href="@mark_ready_url@" class="action">Mark this template ready for use</a>
              </if>

              <if @inst_url@ not nil>
                <a href="@inst_url@" class="action">Start a simulation with this template</a>
              </if>

              <a href="@delete_url@" class="action" 
                onclick="return confirm('Are you sure you want to delete the template?');">Delete this template</a>


          </div>
        </div>

        <div class="portlet">
          <h2>States</h2>
          <div class="portlet-body">
            <include src="/packages/simulation/lib/sim-template-states" workflow_id="@workflow_id@">
          </div>
        </div>
      </td>
      <td>
        <div class="portlet">
          <a name="roles"><h2>Roles</h2></a>
          <div class="portlet-body">
            <include src="/packages/simulation/lib/sim-template-roles" workflow_id="@workflow_id@" display_mode="edit">
          </div>
        </div>
      </td>
    </tr>

    <tr>
      <td valign="top" colspan="2">
        <div class="portlet">
          <a name="tasks"><h2>Tasks</h2></a>
          <div class="portlet-body">
            <include src="/packages/simulation/lib/sim-template-tasks" workflow_id="@workflow_id@" display_mode="edit" >
          </div>
        </div>
      </td>
    </tr>
  </table>

</else>
