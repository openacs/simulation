<if @num_groups@ eq 0>

  <div class="general-message">#simulation.lt_There_are_no_particip#</div>

</if>

<else>

<p>
    #simulation.lt_Each_role_may_be_play#
</p>

<formtemplate id="actors"></formtemplate>

<if @all_tabs_complete_p@ false>
  <div class="general-message">#simulation.lt_You_cannot_submit_thi#</div>
</if>

<if @sim_template.sim_type@ eq "casting_sim">
  <div class="general-message">#simulation.lt_Warning_this_simulati#</div>
</if>

</else>

