

<formtemplate id="simulation">

  <listtemplate name="participants"></listtemplate>

  <p>TODO: figure out when to execute auto-enrollment (and update the
  help text below).  choices:
<ul>
<li>When Finish is clicked in the wizard
<li>When Next is clicked on this page
<li>When "Perform Auto-enroll" button on this page is selected
<li>When enrollment end date is reached (issue: may not always exist)
<li>When sim start time is reached
</ul>
  <p class="form-help-text"><b>Auto-Enroll</b> takes effect, and
  <b>invitations</b> are sent, when this wizard is completed and
  casting begins.</p>

  <formwidget id="wizard_submit_back"> <formwidget id="wizard_submit_next">

</formtemplate>

<a href="@group_admin_url@" class="action">Manage groups</a>
