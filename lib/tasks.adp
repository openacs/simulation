<if @complete_p@ true>
  <i>This case has been completed.</i>
</if>
<else>
  <if @workflow_id@ not nil>
    <formtemplate id="search"></formtemplate>
  </if>
  
  <listfilters name="tasks" style="inline-filters"></listfilters>
  <listtemplate name="tasks"></listtemplate></p>
</else>
