<master>
  <property name="title">@page_title;noquote@</property>
  <property name="context">@context;noquote@</property>

<p><listtemplate name="objects"></listtemplate></p>

<p>
  <b>&raquo;</b> <a href="@create_object_url@">Create new object</a>
</p>

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