<master src="/packages/simulation/www/simulation-master">
  <property name="title">@page_title;noquote@</property>
  <property name="context">@context;noquote@</property>


<if @deletable@ not true>
<div class="boxed-user-message">
<h3>#simulation.Warning#</h3>
<if @wfs@>
<p>#simulation.lt_This_item_is_used_in_# <em>(@wf_string@)</em>.</p>
</if>
<if @rels@>
<p>#simulation.lt_This_item_is_related_# <em>(@rel_string@)</em>.</p>
</if>
<p>#simulation.lt_Do_not_delete_it_if_y#</p>
</div>
</if>

<p> #simulation.lt_Are_you_sure_you_want# </p>

<a href="@delete_url@" class="button">#simulation.lt_Yes_delete_the_object#</a> 
&nbsp;&nbsp;&nbsp;&nbsp;
<a href="@cancel_url@" class="button">#simulation.No_cancel#</a>
