<master>
  <property name="title">@page_title;noquote@</property>
  <property name="context">@context;noquote@</property>

<include src="/packages/simulation/lib/sim-objects" size="long" display_mode="edit">

<if @admin_p@>
  <h2>Map XML</h2>

  <p>
  @notification_widget;noquote@
  </p>

  <p>
    <b>&raquo;</b> <a href="map-xml">View Map XML</a>
  </p>

  <p>
    <b>&raquo;</b> <a href="generate-xml">Generate Map XML file and send notifications</a>
  </p>
</if>
