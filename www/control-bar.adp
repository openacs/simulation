<ul class="action-links">
	<if @package_url@ ne @curr_url@>
	  <li><strong><a href="@package_url@">#simulation.Simulation_Home#</a></strong></li>
        </if>
	<else>
	  <li><strong>#simulation.Simulation_Home#</strong></li>
	</else>

	<if @curr_url@ ne "@package_url@yellow-pages">
        <li><a href="@package_url@yellow-pages" title="#simulation.lt_Yellow_Pages_is_the_d#">#simulation.Yellow_Pages#</a></li>
	</if>
	<else>
        <li>#simulation.Yellow_Pages#</li>
	</else>

	<if @curr_url@ ne @history_url@>
        <li><a href="@history_url@">#simulation.Sieberdam_History#</a></li>
	</if>
	<else>
        <li>#simulation.Sieberdam_History#</li>
	</else>

        <if @citybuild_p@ true>
            <li><a href="@package_url@citybuild/" title="#simulation.lt_In_CityBuild_you_can_#">#simulation.CityBuild#</a></li>
        </if>

        <if @simbuild_p@ true>
            <li><a href="@package_url@simbuild/" title="#simulation.lt_Create_new_simulation#">#simulation.SimBuild#</a></li>
        </if>

	<if @siminst_p@ true>
            <li><a href="@package_url@siminst/"  title="#simulation.lt_SimInst_is_used_to_st#">#simulation.SimInst#</a></li>
        </if>


 	<li><a href="@package_url@simplay/" title="#simulation.lt_Join_a_simulation_or_#">#simulation.SimPlay#</a></li>

	<if @curr_url@ ne @info_url@>
        <li><a href="@info_url@">#simulation.SieberdamROCS_Info#</a></li>
	</if>
	<else>
        <li>#simulation.SieberdamROCS_Info#</li>
	</else>

	<if @curr_url@ ne @avail_url@>
        <li><a href="@avail_url@">#simulation.lt_SieberdamROCS_Availab#</a></li>
	</if>
	<else>
        <li>#simulation.lt_SieberdamROCS_Availab#</li>
	</else>

	<if @curr_url@ ne @contact_url@>
        <li><a href="@contact_url@">#simulation.Contact_Info#</a></li>
	</if>
	<else>
        <li>#simulation.Contact_Info#</li>
	</else>

	<if @curr_url@ ne @colophon_url@>
        <li><a href="@colophon_url@">#simulation.Colophon#</a></li>
	</if>
	<else>
        <li>#simulation.Colophon#</li>
	</else>
</ul>