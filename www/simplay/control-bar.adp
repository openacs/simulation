You are <a href="@role.character_url@">@role.character_title@</a>
(@role.role_pretty@)

<if @role.thumbnail_url@ not nil>
  <img src="@role.thumbnail_url@" width="@role.thumbnail_width@" height="@role.thumbnail_height@">
</if>

<p>

<h4>Your Options</if></h4>
<ul>
  <li><a href="@case_home_url@">Case home</a>
  <li><a href="@messages_url@">@message_count@ message<if @message_count@ ne 1>s</if></a>
  <li><if @task_count@ eq 1><a href="@tasks_url@">@task_count@ task</a></if><else><a href="@tasks_url@">@task_count@ tasks</a></else>
  <li><a href="@portfolio_url@">Portfolio</a>
  <li><a href="@about_sim_url@">About this simulation</a>
</ul>
<h4>Contacts</h4>
<ul>
  <multiple name="contacts">
    <li><a href="@contacts.character_url@">@contacts.character_title@</a> (@contacts.role_pretty@)</li>
  </multiple>
</ul>


