#simulation.control_bar_current_player#

<if @role.thumbnail_url@ not nil>
  <img src="@role.thumbnail_url@" width="@role.thumbnail_width@" height="@role.thumbnail_height@">
</if>

<p>

<h4>#simulation.States#</h4>

<ul>
  <multiple name="states">
    <li><if @states.state_id@ eq @states.current_state@><b>@states.pretty_name@</b></if><else>@states.pretty_name@</else></li>
  </multiple>
</ul>

<h4>#simulation.Your_Options#</if></h4>
<ul class="action-links">
  <li><a href="@case_home_url@">#simulation.Case_home#</a>
  <li><a href="@messages_url@">@message_count@ <if @message_count@ eq 1>#simulation.message#</if><else>#simulation.messages#</else></a>
  <li><a href="@tasks_url@">@task_count@ <if @task_count@ eq 1>#simulation.task#</if><else>#simulation.tasks#</else></a>
  <li><a href="@portfolio_url@">#simulation.Portfolio#</a>
  <li><a href="@about_sim_url@">#simulation.lt_About_this_simulation#</a>
  <li><a href="@notifications_url@">#simulation.My_Notifications#</a>
</ul>
<if @show_contacts_p@>
<h4>#simulation.Contacts#</h4>
<ul class="action-links">
  <multiple name="contacts">
    <li><a href="@contacts.character_url@">@contacts.character_title@</a> (@contacts.role_pretty@)</li>
  </multiple>
</ul>
</if>

