<master src="map-master">
  <property name="title">@page_title;noquote@</property>
  <property name="context">@context;noquote@</property>
	
	<div class="index_citybuild">
        <if @citybuild_p@ true>
            <h3><a href="citybuild/">CityBuild</a></h3>
            <include src="/packages/simulation/lib/sim-objects-grouped/" />
        </if>
        </div>

	<div class="index_simbuild"> 
        <if @simbuild_p@ true>
            <h3><a href="simbuild/">SimBuild</a></h3>
            <include src="/packages/simulation/lib/sim-templates" size="short" display_mode="display"/>
        </if>
	</div>
        
	<div class="index_siminst">
	<if @siminst_p@ true>
            <h3><a href="siminst/">SimInst</a></h3>
            <include src="/packages/simulation/lib/sim-insts-grouped"/>
        </if>
	</div>

        <div class="index_simplay">  
 	<h3><a href="simplay/">SimPlay</a></h3>
          <if @user_id@ ne 0>
          <h4>Your Current Simulations</h4>
            <include src="/packages/simulation/lib/cases" party_id="@user_id@"/>
          </if>
          <else>
            <u>Log in</u> to see your active cases.
          </else>
          <p>
          <h4>Join a Simulation</h4>
          <include src="/packages/simulation/lib/simulations-available" party_id="@user_id@"/>
        </div>

        <div class="index_yellow-pages">
          <h3><a href="yellow-pages">Yellow Pages</a></h3>
        </div>
