<master src="/packages/simulation/www/map-master">
<div style="margin: 4px; padding: 4px; border: 1px solid black;">
  <h3><a href="simplay/">SimPlay</a></h3>

  <if @user_id@ ne 0>
    <include src="/packages/simulation/lib/cases" party_id="@user_id@"/>
  </if>
  <else>
    <u>Log in</u> to see your active cases.
  </else>

    <include src="/packages/simulation/lib/simulations-available" party_id="@user_id@"/>
</div>

<div style="margin: 4px; padding: 4px; background: lightgray; border: 1px solid black;">
  <h3><a href="yellow-pages">Yellow Pages</a></h3>

    Todo...
</div>

<div style="margin: 4px; padding: 4px; border: 1px solid black;">
  <h3><a href="citybuild/">CityBuild</a></h3>

  <include src="/packages/simulation/lib/sim-objects" size="short" display_mode="display"/>
</div>

<div style="margin: 4px; padding: 4px; border: 1px solid black;">
  <h3><a href="simbuild/">SimBuild</a></h3>

  <include src="/packages/simulation/lib/sim-templates" size="short" display_mode="display"/>
</div>

<div style="margin: 4px; padding: 4px; background: lightgray; border: 1px solid
black;">
  <h3><a href="siminst/">SimInst</a></h3>
</div>