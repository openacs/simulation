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

<if @sim_template.sim_type@ eq "casting_sim">
  <div class="general-message">Warning: this simulation is already in casting. Clicking the finish button may have unwanted consequences such as sending notifications twice to users.</div>
</if>

</else>

<P>
  TODO: B: (1h) Show total number of users per case. Javascript. Lars?
</p>

<p>
  TODO: B: Some data needs to be read only if you return to the wizard after you've clicked the finish button. Test this.
</p>
