<master>
  <property name="title">@page_title;noquote@</property>
  <property name="context">@context;noquote@</property>

List of eligible templates for instantiation. :
<pre>
select workflow_id,
       suggested_duration,
       pretty_name
       (...) as number_of_roles
       () as min_number_of_human_roles

Each record has a <a href="simulation-edit">Instantiate this template</a>

from workflows
where ready_p = 't'
</pre>

<p>
Sort and filter based on "expected duration" and number
of roles.  Possibly also show "number of roles that can't be played by
an agent" (as "min # of humans")
</p>

<p>
  TODO: Show a list of simulations with no cases so that you can continue working on one that was partially instantiated.
</p>
