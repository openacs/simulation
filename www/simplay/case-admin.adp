<master src="/packages/simulation/www/simulation-master">
  <property name="title">@title;noquote@</property>
  <property name="context">@context;noquote@</property>

<listfilters name="roles" style="inline-filters"></listfilters>
<listtemplate name="roles"></listtemplate>
<p></p>

<if @uncast_role_options@ not nil and @assigned_only_p@ false>
  <h3>Add users in uncast role</h3>

  <formtemplate id="add_user"></formtemplate>
  <p></p>
</if>

<ul class="action-links">
  <li><a href="@case_delete_url@">Delete this case</a></li>
</ul>
