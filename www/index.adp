<master src="map-master">
  <property name="title">@page_title;noquote@</property>
  <property name="context">@context;noquote@</property>

        <if @citybuild_p@ true>
          <div style="margin: 4px; padding: 4px; border: 1px solid black;">
            <h3><a href="citybuild/">#simulation.CityBuild#</a></h3>
            
            <include src="/packages/simulation/lib/sim-objects-grouped/" />
          </div>
        </if>
        
        <if @simbuild_p@ true>
          <div style="margin: 4px; padding: 4px; border: 1px solid black;">
            <h3><a href="simbuild/">#simulation.SimBuild#</a></h3>
            <include src="/packages/simulation/lib/sim-templates" size="short" display_mode="display"/>
          </div>
        </if>

        <if @siminst_p@ true>
          <div style="margin: 4px; padding: 4px; border: 1px solid
               black;">
            <h3><a href="siminst/">#simulation.SimInst#</a></h3>
            <include src="/packages/simulation/lib/sim-insts-grouped"/>
          </div>
        </if>

        <div style="margin: 4px; padding: 4px; border: 1px solid black;">
          <h3><a href="simplay/">#simulation.SimPlay#</a></h3>
          <if @user_id@ ne 0>
          <h4>#simulation.lt_Your_Current_Simulati#</h4>
            <include src="/packages/simulation/lib/cases" party_id="@user_id@"/>
          </if>
          <else>
            <a href="@login_url@">#simulation.Log_in#</a> #simulation.lt_to_see_your_active_ca#
          </else>
          <p>
          <h4>#simulation.Join_a_Simulation#</h4>
          <include src="/packages/simulation/lib/simulations-available" party_id="@user_id@"/>
        </div>

        <div style="margin: 4px; padding: 4px; border: 1px solid black;">
          <h3><a href="yellow-pages">#simulation.Yellow_Pages#</a></h3>
        </div>

