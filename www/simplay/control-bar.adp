<br>You are <a href="/simulation/object/bernadette">Bernadette</a> (Plaintiff)
<img src="/simulation/object-content/new-jersey-lawyers">


<h4>Your Options</if></h4>
<ul>
  <li><a href="@case_home_url@">Case home</a>
  <li><a href="@messages_url@">@message_count@ Messages</a>
  <li><if @task_count@ eq 1><a href="@tasks_url@">@task_count@ Task</a></if><else><a href="@tasks_url@">@task_count@ Tasks</a></else>
  <li><a href="@portfolio_url@">Portfolio</a>
  <li>About this simulation
</ul>
<p>TODO: Link "about this simulation" to simplay/about-sim?sim_id=
<h4>Contacts<if @roles:rowcount@ gt 1>s</if></h4>
<ul>
<li><a href="">Susie Smith</a> (Defense Lawyer)
  <multiple name="roles">
    <li>@roles.pretty_name@</li>
  </multiple>
</ul>


