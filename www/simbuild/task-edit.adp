<master>
  <property name="title">@page_title;noquote@</property>
  <property name="context">@context;noquote@</property>
  <property name="focus">task.name</property>

<formtemplate id="task"></formtemplate>

<p>This is the master task editing form.  For new tasks, we will
instead have a two-part sequence: 1, pick a task type, such as
"GiveInfo".  2) fill out certain pre-selected values relevant to that
task type.
<p>More info per task:
<ul>
<li><b>Enable Conditions</b>.  A list of conditions that must be true
before a task is enabled.  examples: Task1 is Complete.  Task5 is not
started.  Task1 is completed twice.
<li>(B priority): additional recipients
<li><b>Timeout</b>.  Could be none, or a time increment relative to task
being enabled.  After timeout, either the state automatically changes
or (B priority) there is conditional logic to determine a new state
<li><b>Max number of repetitions</b>.  After this task is enabled
(completed?) N times, it cannot be enabled again.  (Is this better
viewed as an enable condition?)
<li><b>Rating</b>.  Recipient (?) is given a list of choices to rate an
input.  Choices of choices: Pass/fail, letter grade, numeric grade.
</ul>

