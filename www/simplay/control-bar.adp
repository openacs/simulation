<h4>Your Options</if></h4>

<ul>
  <li><a href="@messages_url@">@message_count@ Messages</a>
  <li><if @task_count@ eq 1><a href="@tasks_url@">@task_count@ Task</a></if><else><a href="@tasks_url@">@task_count@ Tasks</a></else>
  <li>Archive
  <li>About this simulation
</ul>

<h4>Your Role<if @roles:rowcount@ gt 1>s</if></h4>

<ul>
  <multiple name="roles">
    <li>@roles.pretty_name@</li>
  </multiple>
</ul>


