<master src="/packages/simulation/www/simulation-master">
  <property name="title">@page_title;noquote@</property>
  <property name="context">@context;noquote@</property>

  <include src="/packages/simulation/lib/tasks" workflow_id="@workflow_id@" &="role_id">

  <p>
    If you are using the respond button to respond to multiple tasks
    then all checked tasks must share the same task name.
  </p>