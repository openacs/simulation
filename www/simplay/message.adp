<master src="play-master">
  <property name="title">@page_title;noquote@</property>
  <property name="context">@context;noquote@</property>
  
<p>TODO: this page is for composing new messages and for reading messages.
<p>Form:
<ul>
<li><b>From</b>: in new mode, is read-only of role name.  In read
mode, there should be a reply button which composes a new message,
with the original sender pre-selected in To:, and the old message body
pre-inserted as body (with > spacers?  with html italics?)
<li><b>To</b>: a checkbox list of all roles in the sim, with a "check
all" option
<li><b>Subject</b>
<li><b>Body</b>: text/html field
<li><b>Attachments</b>: A checkbox list of all props associated with
the role. (how do we know which?  We may need a "workflow_case_role to
sim_object" mapping table)?
</ul>
<input type="submit" value="Send">