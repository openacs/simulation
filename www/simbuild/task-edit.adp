<master src="/packages/simulation/www/simulation-master">
  <property name="title">@page_title;noquote@</property>
  <property name="context">@context;noquote@</property>
  <property name="focus">task.pretty_name</property>

<formtemplate id="task"></formtemplate>
TODO: If there are no states, show a message "This task cannot be
fully developed because its workflow has no states" and link to add states
