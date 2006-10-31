
<div class="simplay_control-bar_block">
<p>
#simulation.You_are# <a href="@role.character_url@">@role.character_title@</a>
(@role.role_pretty@)
</p>


<if @role.thumbnail_url@ not nil>
<p>
  <img src="@role.thumbnail_url@" width="@role.thumbnail_width@" height="@role.thumbnail_height@">
</p>
</if>

<if @show_states_p@>
<p><strong>@curr_state@:</strong> @state_name@</p>
</if>

</div>

<div class="simplay_control-bar_block">
<h4>#simulation.Your_Options#</h4>
<ul class="action-links">
<li><strong>
<if @case_home_url@ ne @current_url@>
<a href="@case_home_url@">#simulation.Session_Home#</a>
</if>
<else>
#simulation.Session_Home#
</else>
</strong>
</li>

<li>
<a href="@messages_url@">#simulation.Messages# [@message_count@]</a>
</li>
  <li><a href="@tasks_url@">#simulation.Tasks# [@task_count@]</a></li>
  <li><a href="@portfolio_url@">#simulation.Portfolio#</a></li>
  <li><a href="@map_url@">#simulation.Sieberdam_Map#</a></li>
  <li><a href="@yp_url@">#simulation.Yellow_Pages#</a></li>
  <li><a href="@history_url@">#simulation.Sieberdam_History#</a></li>
  <li><a href="@about_sim_url@">#simulation.lt_About_this_simulation#</a></li>
  <li><a href="@notifications_url@">#simulation.Notifications#</a></li>
  <li><a href="@help_url@">#simulation.Simplay_Help#</a></li>
</ul>

</div>

<if @show_contacts_p@>
<div class="simplay_control-bar_block">
<h4>#simulation.Contacts#</h4>
<ul class="action-links">
  <multiple name="contacts">
    <li><a href="@contacts.character_url@">@contacts.character_title@</a> (@contacts.role_pretty@)</li>
  </multiple>
</ul>
</div>
</if>