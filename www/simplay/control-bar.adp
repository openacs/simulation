
<div class="simplay_control-bar_you-are">
#simulation.You_are# <a href="@role.character_url@">@role.character_title@</a>
(@role.role_pretty@)
</div>

<div class="simplay_control-bar_thumbnail">
<if @role.thumbnail_url@ not nil>
  <img src="@role.thumbnail_url@" width="@role.thumbnail_width@" height="@role.thumbnail_height@">
</if>
</div>

<if @show_states_p@>
<p><strong>@curr_state@:</strong> @state_name@</p>
</if>

<div class="simplay_control-bar_options">
<h4>#simulation.Your_Options#</if></h4>
<ul class="action-links">
<li class="simplay_control-bar_options_case-home"><strong>
<if @case_home_url@ ne @current_url@>
<a href="@case_home_url@">#simulation.Session_Home#</a>
</if>
<else>
#simulation.Home#
</else>
</strong>
</li>

<li>
<a href="@messages_url@">#simulation.Messages# [@message_count@]</a>
</li>
  <li><a href="@tasks_url@">#simulation.Tasks# [@task_count@]</a></li>
  <li><a href="@map_url@">#simulation.Sieberdam_Map#</a></li>
  <li><a href="@yp_url@">#simulation.Yellow_Pages#</a></li>
  <li><a href="@portfolio_url@">#simulation.Portfolio#</a></li>
  <li><a href="@about_sim_url@">#simulation.lt_About_this_simulation#</a></li>
  <li><a href="@notifications_url@">#simulation.Notifications#</a></li>
  <li><a href="@help_url@">#simulation.Simplay_Help#</a></li>
</ul>

</div>

<if @show_contacts_p@>
<div class="simplay_control-bar_contacts">
<h4>#simulation.Contacts#</h4>
<ul class="action-links">
  <multiple name="contacts">
    <li><a href="@contacts.character_url@">@contacts.character_title@</a> (@contacts.role_pretty@)</li>
  </multiple>
</ul>
</div>
</if>


