<master>
  <property name="title">@page_title;noquote@</property>
  <property name="context">@context;noquote@</property>
  <property name="header_stuff">
      <link rel="stylesheet" type="text/css" href="@stylesheet_url@" media="all">
  </property>

<if @content_html@ not nil>@content_html;noquote@</if>

<if @edit_url@ not nil>
  <p>
    <a href="@edit_url@" class="button">Edit</a>
  </p>
</if>
<p>TODO: edit_url shouldn't show up if user doesn't have permission to
  edit object