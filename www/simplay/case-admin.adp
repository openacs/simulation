<master src="/packages/simulation/www/simulation-master">
  <property name="title">@title;noquote@</property>
  <property name="context">@context;noquote@</property>

<listfilters name="roles" style="inline-filters"></listfilters>
<listtemplate name="roles"></listtemplate>
<p></p>

<div class="simplay_case-admin_uncast">
  <if @uncast_role_options@ not nil and @assigned_only_p@ false>
    <h2>#simulation.lt_Add_users_in_uncast_r#</h2>

    <formtemplate id="add_user"></formtemplate>
    <p></p>
  </if>
</div>

<div class="simplay_case-admin_action-links">
  <ul class="action-links">
    <li><a href="@case_delete_url@">#simulation.Abort_the_session#</a></li>
    <li><a href="@section_uri@">#simulation.Return_to_SimPlay#</a></li>
  </ul>
</div>

<div class="simplay_case-admin_history">
  <h2>#simulation.Case_History#</h2>
  <p> 	 
    <a href="@full_history_url@">#simulation.lt_Export_full_case_hist#</a> 	 
  </p> 	 
  <include src="/packages/simulation/lib/case-history" case_id="@case_id@" />
</div>

