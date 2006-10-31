<master src="play-master">
  <property name="title">@title;noquote@</property>
  <property name="context">@context;noquote@</property>

<div class="simplay_case_block">
<if @portfolio_orderby@ >
<include src="/packages/simulation/lib/portfolio" case_id="@case_id@" role_id="@role_id@" portfolio_orderby="@portfolio_orderby@">
</if>
<else>
<include src="/packages/simulation/lib/portfolio" case_id="@case_id@" role_id="@role_id@">
</else>
</div>