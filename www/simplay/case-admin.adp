<master src="/packages/simulation/www/simulation-master">
  <property name="title">@title;noquote@</property>
  <property name="context">@context;noquote@</property>

  @assigned_filter;noquote@

  <p>
    <listtemplate name="roles"></listtemplate>
  </p>

  <if @uncast_role_options@ not nil>
    <h3>Add users in uncast role</h3>
  
    <p>
      <formtemplate id="add_user"></formtemplate>
    </p>
  </if>

<p>
TODO: Remove the assigned filter and make the table always show all roles and any assigned actions for each role. Lars?
</p>

<p>
TODO: Group by role_id. Need some help from Lars.
</p>
