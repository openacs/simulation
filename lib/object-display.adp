<master>
  <property name="title">@page_title;noquote@</property>
  <property name="context">@context;noquote@</property>


<if @content_html@ not nil>@content_html;noquote@</if>

<if @edit_url@ not nil><a href="@edit_url@" class="button">Edit</a></if>
