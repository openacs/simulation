<if @num_groups@ eq 0>

  <div class="general-message">Please pick participants first.</div>

</if>

<else>

<p>
    Each role may be played by one or by
    many users.  Each role can only be played by users in the group
    specified below.  If a group is not selected for any role, user
    in that group will not be cast in the simulation
</p>

<formtemplate id="actors"></formtemplate>
<P>TODO: Show total number of users per case

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

<p>TODO: if enroll-type is open, show all groups from the subsite in
each role
<P>TODO: Number of users should by greater than 0.
<p>TODO: auto-check all boxes by default


