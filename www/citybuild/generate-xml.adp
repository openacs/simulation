<master src="/packages/simulation/www/simulation-master">
  <property name="title">@page_title;noquote@</property>
  <property name="context">@context;noquote@</property>

<if @result.wrote_file_p@>
  <p>
    #simulation.lt_Generated_map_XML_fil#
  </p>
</if>
<else>
  <p>
    #simulation.lt_Did_not_generate_an_X#
  </p>  
</else>

<if @result.errors@ not nil>
#simulation.lt_The_following_errors#

<pre>
@error_text@
</pre>

</if>

