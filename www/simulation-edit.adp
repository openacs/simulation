<master>
  <property name="title">@page_title;noquote@</property>
  <property name="context">@context;noquote@</property>

<p>TODO:  add/edit page for simulations.
In add mode, show a list of valid templates (incomplete - rules for
determining which templates are valid) that can be instantiated.
Specify Enrollment start, end; case start, end.
<p>TODO: list of simulations needs to be sortable by "expected
duration" and "recommended group size".  We can either add those
attributes to "sim_workflows," which would be a new extension table for
"workflows," or we can try to use the categories packages.  It's worth
putting a few hours into categories, but if we don't have something
working at that point we should abandon it and use sim_workflows
instead.
