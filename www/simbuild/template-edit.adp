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
          <h2>#simulation.Template#</h2>
          <div class="portlet-body">
            <formtemplate id="sim_template"></formtemplate>
            <ul class="action-links">
              <if @mark_ready_url@ not nil>
                <li><a href="@mark_ready_url@">#simulation.lt_Mark_this_template_re#</a></li>
              </if>
              <li><a href="@spec_url@">#simulation.lt_Export_this_template#</a></li>
            </ul>

          </div>
        </div>

        <div class="portlet">
          <h2>#simulation.States#</h2>
          <div class="portlet-body">
            <include src="/packages/simulation/lib/sim-template-states" workflow_id="@workflow_id@">
          </div>
        </div>
      </td>
      <td valign="top">
        <div class="portlet">
          <a name="roles"><h2>#simulation.Roles#</h2></a>
          <div class="portlet-body">
            <include src="/packages/simulation/lib/sim-template-roles" workflow_id="@workflow_id@" display_mode="edit">
          </div>
        </div>
      </td>
    </tr>

    <tr>
      <td valign="top" colspan="2">
        <div class="portlet">
          <a name="tasks"><h2>#simulation.Tasks#</h2></a>
          <div class="portlet-body">
            <include src="/packages/simulation/lib/sim-template-tasks" workflow_id="@workflow_id@" display_mode="edit" >
          </div>
        </div>
      </td>
    </tr>
  </table>

</else>

<ul class="action-links">
<li><a href="@package_url@simbuild/">#simulation.lt_Return_to_SimBuild_Ho#</a></li>
<li><a href="@package_url@">#simulation.lt_Return_to_Simulation__1#</a></li>
</ul>