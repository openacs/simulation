You are <a href="/simulation/object/bernadette">Bernadette</a>
(Plaintiff) (TODO: make this real)
<img src="/simulation/object-content/new-jersey-lawyers">
<h4>Your Options</if></h4>
<ul>
  <li><a href="@case_home_url@">Case home</a>
  <li><a href="@messages_url@">@message_count@ Messages</a>
  <li><if @task_count@ eq 1><a href="@tasks_url@">@task_count@ Task</a></if><else><a href="@tasks_url@">@task_count@ Tasks</a></else>
  <li><a href="@portfolio_url@">Portfolio</a>
  <li><a href="@about_sim_url@">About this simulation</a>
</ul>
<h4>Contacts<if @roles:rowcount@ gt 1>s</if></h4>
<ul>
  <multiple name="roles">
    <li><a href="@roles.character_url@">@roles.pretty_name@</a> (@roles.role_name@)</li>
  </multiple>
</ul>


