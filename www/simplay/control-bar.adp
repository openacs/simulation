<h4>Your Options</if></h4>

<ul>
  <li><a href="@messages_url@">@message_count@ Messages</a>
  <li><if @task_count@ eq 1><a href="@tasks_url@">@task_count@ Task</a></if><else><a href="@tasks_url@">@task_count@ Tasks</a></else>
  <li>Archive
  <li>About this simulation
</ul>
<p>TODO: link Archive to "portfolio" of all objects this actor owns
  (since the actor is specific to role and case, these are objects in the same case)
<p>TODO: Link "about this simulation" to something
<h4>Your Role<if @roles:rowcount@ gt 1>s</if></h4>

<ul>
  <multiple name="roles">
    <li>@roles.pretty_name@</li>
  </multiple>
</ul>


