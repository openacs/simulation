<master src="/packages/simulation/www/simulation-master">
  <property name="title">@page_title;noquote@</property>
  <property name="context">@context;noquote@</property>

<include src="/packages/simulation/lib/sim-objects" size="long" display_mode="edit" &="orderby" &="type">
<p></p>

<if @map_p@>
  <h2>#simulation.Map_XML#</h2>

  <ul class="action-links">
    <if @subscribe_url@ not nil>
      <li><a href="@subscribe_url@">#simulation.lt_Notify_me_of_changes#</a></li>
    </if>
    <if @unsubscribe_url@ not nil>
      <li><a href="@unsubscribe_url@">#simulation.lt_Stop_notifying_me_of#</a></li>
    </if>
    <li><a href="map-xml">#simulation.View_Map_XML#</a></li>
    <li><a href="generate-xml">#simulation.lt_Generate_Map_XML_file#</a></li>
  </ul>
</if>

