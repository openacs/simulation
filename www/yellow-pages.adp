<master src="normal-master">
  <property name="title">@page_title;noquote@</property>
  <property name="context">@context;noquote@</property>

<p>
  <if @yp_orderby@>	
  <include src="/packages/simulation/lib/yellow-pages" yp_orderby="@yp_orderby@">
  </if>
  <else>
  <include src="/packages/simulation/lib/yellow-pages">
  </else>


</p>
