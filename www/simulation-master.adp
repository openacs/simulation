<master>
  <property name="title">@title;noquote@</property>
  <property name="context">@context;noquote@</property>
  <property name="subnavbar_link">@subnavbar_link;noquote@</property>
  <if @focus@ not nil><property name="focus">@focus;noquote@</property></if>

<property name="header_stuff">    
  <link rel="stylesheet" type="text/css" href="@base_url@resources/under-construction.css" media="all">
  @header_stuff;noquote@
</property>


<slave>