<master src="play-master">
  <property name="title">@page_title;noquote@</property>
  <property name="context">@context;noquote@</property>

<p>
  <if @yp_orderby@>	
  <include src="/packages/simulation/lib/yellow-pages" yp_orderby="@yp_orderby@" case_id="@case_id@" role_id="@role_id@" />
  </if>
  <else>
  <include src="/packages/simulation/lib/yellow-pages" case_id="@case_id@" role_id="@role_id@" />
  </else>


</p>
