<if @complete_p@ true>
  <i>#simulation.lt_This_case_has_been_co#</i>
</if>
<else>
  <if @workflow_id@ not nil>
    <formtemplate id="search"></formtemplate>
  </if>
  
  <listfilters name="tasks" style="inline-filters"></listfilters>
  <listtemplate name="tasks"></listtemplate></p>
</else>

