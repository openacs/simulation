<master src="/packages/simulation/www/simulation-master">
  <property name="title">@page_title;noquote@</property>
  <property name="context">@context;noquote@</property>


<table width="100%">
  <tr>
    <td valign="top">
      <div class="portlet">
        <h2>Template</h2>
        <div class="portlet-body">
          <formtemplate id="task"></formtemplate>
          
          <ul class="action-links">
            <if @parent_action_url@ not nil>
              <li><a href="@parent_action_url@">Up to @parent_task_array.pretty_name@</a></li>
            </if>
            <li><a href="@template_url@">Back to template @sim_template_array.pretty_name@</a></li>
          </ul>
        </div>
      </div>
    </td>
  </tr>

  <tr>
    <td valign="top" colspan="2">
      <div class="portlet">
        <a name="tasks"><h2>Tasks</h2></a>
        <div class="portlet-body">
          <include src="/packages/simulation/lib/sim-template-tasks" workflow_id="@workflow_id@" display_mode="edit" parent_action_id="@action_id@">
        </div>
      </div>
    </td>
  </tr>
</table>
