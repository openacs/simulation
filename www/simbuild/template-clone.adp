<master src="/packages/simulation/www/simulation-master">
  <property name="title">@page_title;noquote@</property>
  <property name="context">@context;noquote@</property>
  <property name="focus">clone.pretty_name</property>

<formtemplate id="clone"></formtemplate>

<p>Make a copy of the selected template, including all tasks and
roles, but not any objects.  (At the moment, there shouldn't be any
objects associated with a template, but that might change.  If so,
copy links to objects but not the objects themselves.)
