<master>
  <property name="title">@page_title;noquote@</property>
  <property name="context">@context;noquote@</property>

<p>@name@ has dependent tasks.  Do you want to delete this role
and all related tasks?<?p>

<h4>Related Tasks</h4>
<include src="/packages/simulation/lib/sim-template-tasks" workflow_id=@workflow_id@ package_id=@package_id@>
</if>

<p>
  <b>&raquo;</b> <a href="@delete_url@">Delete @name@ and tasks</a>
</p>

<p>
  <b>&raquo;</b> <a href="@cancel_url@">Cancel</a>
</p>

