<master>
  <property name="title">@page_title;noquote@</property>
  <property name="context">@context;noquote@</property>
  <property name="header_stuff">
    <if @stylesheet_url@ not nil>
      <link rel="stylesheet" type="text/css" href="@stylesheet_url@" media="all">
    </if>
  </property>


<if @content_html@ not nil>@content_html;noquote@</if>

<if @edit_url@ not nil><a href="@edit_url@" class="button">Edit</a></if>
