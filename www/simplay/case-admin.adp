<master src="/packages/simulation/www/simulation-master">
  <property name="title">@title;noquote@</property>
  <property name="context">@context;noquote@</property>

<listfilters name="roles" style="inline-filters"></listfilters>
<listtemplate name="roles"></listtemplate>
<p></p>

<div class="simplay_case-admin_uncast">
<if @uncast_role_options@ not nil and @assigned_only_p@ false>
  <h2>Add users in uncast role</h2>

  <formtemplate id="add_user"></formtemplate>
  <p></p>
</if>
</div>

<div class="simplay_case-admin_action-links">
<ul class="action-links">
  <li><a href="@case_delete_url@">Delete this case</a></li>
</ul>
</div>

<div class="simplay_case-admin_history">
<h2>Case History</h2>
<listtemplate name="log"></listtemplate>
</div>
