<h3>Tasks</h3>
<p>
  <listtemplate name="log"></listtemplate>
<p>

<if @actions_only_p@ false>

  <h3>Messages</h3>
  <p>
    <include src="/packages/simulation/lib/messages" case_id="@case_id@" show_body_p="@show_body_p@">
  </p>

  <h3>Documents</h3>
  <p>
    <listtemplate name="documents"></listtemplate>
  </p>

</if>
