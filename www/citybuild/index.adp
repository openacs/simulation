<master src="/packages/simulation/www/simulation-master">
  <property name="title">@page_title;noquote@</property>
  <property name="context">@context;noquote@</property>

<include src="/packages/simulation/lib/sim-objects" size="long" display_mode="edit" &="orderby" &="type">
<p></p>

<if @map_p@>
  <h2>Map XML</h2>

  <p>
  @notification_widget;noquote@
  </p>

  <a href="map-xml" class="action">View Map XML</a>
  <a href="generate-xml" class="action">Generate Map XML file and send notifications</a>
</if>
