<master src="/packages/simulation/www/simulation-master">
  <property name="title">@page_title;noquote@</property>
  <property name="context">@context;noquote@</property>

<div class="help-link"><a href="@help_url@">#simulation.SimBuild_Help#</a></div>

<if @sb_orderby@>
<include src="/packages/simulation/lib/sim-templates" size="long" sb_orderby="@sb_orderby@">
</if>
<else>
<include src="/packages/simulation/lib/sim-templates" size="long">
</else>

<ul class="action-links">
<li><a href="@package_url@">#simulation.lt_Return_to_Simulation__1#</a></li>
</ul>