<master>
  <property name="title">@title;noquote@</property>
  <property name="context">@context;noquote@</property>

<property name="header_stuff">    
  <link rel="stylesheet" type="text/css" href="resources/under-construction.css" media="all">
</property>
<if @admin_p@>
  <property name="subnavbar_link">
      <a href="@parameters_url@">Configuration</a> | <a
       href="doc">Documentation</a> | <a href="/test/admin/index?by_package_key=simulation&view_by=testcase&quiet=0">Tests</a>
</property>
</if>
<slave>

