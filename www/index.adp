<master src="map-master">
  <property name="title">@page_title;noquote@</property>
  <property name="context">@context;noquote@</property>

        <if @citybuild_p@ true>
          <div style="margin: 4px; padding: 4px; border: 1px solid black;">
            <h3><a href="citybuild/">CityBuild</a></h3>
            
            <include src="/packages/simulation/lib/sim-objects-grouped/" />
          </div>
        </if>
        
        <if @simbuild_p@ true>
          <div style="margin: 4px; padding: 4px; border: 1px solid black;">
            <h3><a href="simbuild/">SimBuild</a></h3>
            <include src="/packages/simulation/lib/sim-templates" size="short" display_mode="display"/>
          </div>
        </if>

        <if @siminst_p@ true>
          <div style="margin: 4px; padding: 4px; border: 1px solid
               black;">
            <h3><a href="siminst/">SimInst</a></h3>
            <include src="/packages/simulation/lib/sim-insts-grouped"/>
          </div>
        </if>

        <div style="margin: 4px; padding: 4px; border: 1px solid black;">
          <h3><a href="simplay/">SimPlay</a></h3>
          <if @user_id@ ne 0>
          <h4>Your Current Simulations</h4>
            <include src="/packages/simulation/lib/cases" party_id="@user_id@"/>
          </if>
          <else>
            <u>Log in</u> to see your active cases.
          </else>
          <p>
          <h4>Join a Simulations</h4>
          <include src="/packages/simulation/lib/simulations-available" party_id="@user_id@"/>
        </div>

        <div style="margin: 4px; padding: 4px; border: 1px solid black;">
          <h3><a href="yellow-pages">Yellow Pages</a></h3>
        </div>
