<master src="play-master">
  <property name="title">@page_title;noquote@</property>
  <property name="context">@context;noquote@</property>
  
  <include src="/packages/simulation/lib/tasks" user_id="@user_id@"></include>

<p>TODO: means (sort,filter, checkboxes) to select a bunch of pending
tasks and send an identical response to all.  restrict to privilege
AdminPlayer on package_id.
