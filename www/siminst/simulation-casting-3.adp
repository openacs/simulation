<if @num_groups@ eq 0>

  <div class="general-message">There are no participants selected, so casting is not yet possible. On the previous tab, please select participants or allow open enrollment.</div>

</if>

<else>

<p>
    Each role may be played by one or by
    many users.  Each role can only be played by users in the group
    specified below.  If a group is not selected for any role, user
    in that group will not be cast in the simulation
</p>

<formtemplate id="actors"></formtemplate>
<P>TODO: (0.1h) Show total number of users per case

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

<p>TODO: (0.5h) if enroll-type is open, show all groups from the subsite in
each role

<p> TODO: (2h) Make sure rule for checking each tab is correct</p>
<p> TODO: (3h) put a warning next to the finish button for any incomplete
requirements, using the same tests we use to determine if tabs are
complete.  Should include:

Warnings:
<ul>
<li>missing attachments
</ul>

Don't show wizard button if any of these are true:
<ul>
<li>missing dates
<li>any invited or enrolled groups that aren't cast to any roles
</ul>

<p>
TODO: B: finish button should appear on every tab
</p>
 
<p>TODO: (8h) make sure that we are generating all of the notifications
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
