<master src="/packages/simulation/www/simulation-master">
  <property name="title">@page_title;noquote@</property>
  <property name="context">@context;noquote@</property>


<table width="100%">
  <tr>
    <td valign="top">
      <div class="portlet">
        <h2>#simulation.Parent_Task#</h2>
        <div class="portlet-body">
          <formtemplate id="task"></formtemplate>
          
          <ul class="action-links">
            <if @parent_action_url@ not nil>
              <li><a href="@parent_action_url@">#simulation.lt_Up_to_parent_task_arr#</a></li>
            </if>
            <li><a href="@template_url@">#simulation.lt_Back_to_template_sim#</a></li>
          </ul>
        </div>
      </div>
    </td>
    <if @task_array.trigger_type@ eq "workflow">
      <td valign="top">
        <div class="portlet">
          <h2>#simulation.Sub-States#</h2>
          <div class="portlet-body">
            <include src="/packages/simulation/lib/sim-template-states" workflow_id="@workflow_id@" parent_action_id="@action_id@">
          </div>
        </div>
      </td>
    </if>
  </tr>

  <tr>
    <td valign="top" colspan="2">
      <div class="portlet">
        <a name="tasks"><h2>#simulation.Sub-Tasks#</h2></a>
        <div class="portlet-body">
          <include src="/packages/simulation/lib/sim-template-tasks" workflow_id="@workflow_id@" display_mode="edit" parent_action_id="@action_id@">
        </div>
      </div>
    </td>
  </tr>
</table>

