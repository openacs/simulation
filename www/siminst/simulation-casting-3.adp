<if @num_groups@ eq 0>

  <div class="general-message">There are no participants selected, so casting is not yet possible. On the previous tab, please select participants, or allow open enrollment on the first tab.</div>

</if>

<else>

<p>
    Each role may be played by one or by
    many users.  Each role can only be played by users in the groups
    specified below.  If a group is not selected for any role, users
    in that group will not be cast in the simulation
</p>

<formtemplate id="actors"></formtemplate>

<if @all_tabs_complete_p@ false>
  <div class="general-message">You cannot submit this form until you have submitted all forms on the previous tabs.</div>
</if>

    <p>In <b>Automatic</b> casting, only

    users from these groups will be assigned to the roles.  All user

    from all selected groups will be cast.  If all users for one rol

    are cast before all users for another role are cast, you will b

    cast as many times as needed to fill out the cases.  (You ca

    change casting assignments <a href="">here</a>.

    <p>In <b>Group</b> casting, users can choose which case to join

    Users are still restricted by group/role limits set below (e.g.

    if each case requires three users from group X and two from grou

    Y, the fourth user from group X to try to join will b

    rejected.). 

    <p>In <b>Open</b> casting, users can choose which case and role t

    join, subject to the restrictions below

</else>

<P>
  TODO: B: (1h) Show total number of users per case. Javascript. Lars?
</p>

<p>
  TODO: (8h) make sure that we are generating all of the notifications
  that we should:

  <ul>
  <li>When a user is enrolled, if casting type is open or group, send a
  notification with a link to the casting page (on finish button)
  <li>When a user is invited, send a link to the enrollment page (on finish button)
  <li>When simulation notification date is reached, send an email saying
  that the simulation will start at date X.  Include the description.
  <li>When the simulation starts, send an email with a link to simplay
  with case_id
  </ul>
</p>

<p>
  TODO: A: Some data needs to be read only if you return to the wizard after you've clicked the finish button. Test this.
</p>
