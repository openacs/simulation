<master src="play-master">
  <property name="title">@page_title;noquote@</property>
  <property name="context">@context;noquote@</property>
  <property name="focus">@focus;noquote@</property>
  
<formtemplate id="message"></formtemplate>


<p>Form:
<ul>
<li><b>Attachments</b>: A checkbox list of all props associated with
the role. (how do we know which?  We may need a "workflow_case_role to
sim_object" mapping table)?
</ul>

TODO: On-refresh on "From" field; changes the "To" field to exclude the "From" role (you can't send to yourself), and changes the list of possible attachments (see above note)
