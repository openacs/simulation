<master src="/packages/simulation/www/simulation-master">
  <property name="title">@title;noquote@</property>
  <property name="context">@context;noquote@</property>

<listfilters name="roles" style="inline-filters"></listfilters>
<listtemplate name="roles"></listtemplate>
<p></p>

<if @uncast_role_options@ not nil and @assigned_only_p@ false>
  <h2>Add users in uncast role</h2>

  <formtemplate id="add_user"></formtemplate>
  <p></p>
</if>

<ul class="action-links">
  <li><a href="@case_delete_url@">Delete this case</a></li>
</ul>

<hr />

<h2>Case History</h2>

@case_history_filter;noquote@

<h3>Actions</h3>
<p>
  <listtemplate name="log"></listtemplate>
<p>

<if @actions_only_p@ false>

  <h3>Messages</h3>
  <p>
    <include src="/packages/simulation/lib/messages" case_id="@case_id@">
  </p>

  <h3>Documents</h3>
  <p>
    <listtemplate name="documents"></listtemplate>
  </p>

</if>