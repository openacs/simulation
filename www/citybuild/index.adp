<master src="/packages/simulation/www/simulation-master">
  <property name="title">@page_title;noquote@</property>
  <property name="context">@context;noquote@</property>

<include src="/packages/simulation/lib/sim-objects" size="long" display_mode="edit" &="orderby" &="type">
<p></p>

<if @map_p@>
  <h2>Map XML</h2>

  <ul class="action-links">
    <if @subscribe_url@ not nil>
      <li><a href="@subscribe_url@">Notify me of changes to map XML</a></li>
    </if>
    <if @unsubscribe_url@ not nil>
      <li><a href="@unsubscribe_url@">Stop notifying me of changes to map XML</a></li>
    </if>
    <li><a href="map-xml">View Map XML</a></li>
    <li><a href="generate-xml">Generate Map XML file and send notifications</a></li>
  </ul>
</if>
