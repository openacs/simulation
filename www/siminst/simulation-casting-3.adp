<if @eligible_groups@ nil>
  <p>
    You haven't picked any groups yet.
  </p>
  <a href="@pick_groups_url@" class="action">Pick groups now</a>
</if>
<else>
  <formtemplate id="actors"></formtemplate>
</else>

<p>
TODO: Display the actor list and group size in parallel columns
instead of in pairs of rows
</p>

<p>TODO: at the bottom, show a list of all groups that are
auto-enrolled but are not assigned anywhere (and hence won't be in any cases)
