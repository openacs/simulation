<if @sim_template.sim_type@ ne "casting_sim">
  <p>
    You have not yet started casting this simulation.
  </p>
  <p>
    Once you start casting, you can no longer change the roles mapping or task setup.
  </p>
  <a href="@begin_casting_url@" class="action">Begin casting now</a>
</if>
<else>
  <formtemplate id="simulation"></formtemplate>
  <p>TODO: implement invitations.
  <p>TODO: When switching from open enrollment to "by invitation only" and back, the dates are lost -- see if we can avoid that.
</else>
