<master>
  <property name="title">@page_title;noquote@</property>
  <property name="context">@context;noquote@</property>

<if @result.wrote_file_p@>
  <p>
    Generated map XML file and sent any notifications.
  </p>
</if>
<else>
  <p>
    Did not generate an XML file.
  </p>  
</else>

<if @result.errors@ not nil>
The following errors were encountered:

<pre>
@error_text@
</pre>

</if>
