<if @num_groups@ eq 0>
  <div class="general-message">Please pick participants first.</div>
</if>
<else>
  <p>
    Pick which groups can be cast in which roles below.
  </p>
  <formtemplate id="actors"></formtemplate>
</else>


<p>
TODO: Display the actor list and group size in parallel columns
instead of in pairs of rows
</p>

<p>TODO: at the bottom, show a list of all groups that are
auto-enrolled but are not assigned anywhere (and hence won't be in any cases)
