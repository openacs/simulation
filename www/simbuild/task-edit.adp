<master>
  <property name="title">@page_title;noquote@</property>
  <property name="context">@context;noquote@</property>
  <property name="focus">task.name</property>

<p>TODO: selecting task type refreshes form (as in ../citybuild/sim-objects)
<br><input type="radio" name="type">AskInfo</input>
<br><input type="radio" name="type">GiveInfo</input>
<br><input type="radio" name="type">ReviewInfo</input>

<formtemplate id="task"></formtemplate>

<p>This is the master task editing form.  For new tasks, we will
instead have a two-part sequence: 1, pick a task type, such as
"GiveInfo".  2) fill out certain pre-selected values relevant to that
task type.
<p>More info per task:  MOCKUPS:
<ul>
<li><b>Simple Enabled if:</b>
<table border=1 cellspacing=0 cellpadding=3>
  <tr>
    <th>Task</th>
    <th>Min Completions</th>
    <th>Max Completions</th>
  </tr>
  <tr>
    <td>
      <select>
       <option label="foo">Task #1: Lawyer1 AskInfo from Client2</option>
       <option label="foo">Task #2: Lawyer2 AskInfo from Client1</option>
       <option label="foo">Task #3: Client2 GiveInfo to Lawyer1</option>
       <option label="foo">Task #4: Client1 GiveInfo to Lawyer2</option>
       </select>
       </td>
       <td><input type="text" size="2"></td>
       <td><input type="text" size="2"></td>
    </tr>
  <tr>
    <td>
      <select>
       <option label="foo">Task #1: Lawyer1 AskInfo from Client2</option>
       <option label="foo">Task #2: Lawyer2 AskInfo from Client1</option>
       <option label="foo">Task #3: Client2 GiveInfo to Lawyer1</option>
       <option label="foo">Task #4: Client1 GiveInfo to Lawyer2</option>
       </select>
       </td>
       <td><input type="text" size="2"></td>
       <td><input type="text" size="2"></td>
    </tr>

</table>


<li><b>Fancy Enabled if:</b>
<table border=1 cellspacing=0 cellpadding=3>
  <tr>
    <th></th>
    <th>Task</th>
    <th></th>
    <th>State</th>
  </tr>
  <tr>
    <td></td>
    <td>
      <select>
       <option label="foo">Task #1: Lawyer1 AskInfo from Client2</option>
       <option label="foo">Task #2: Lawyer2 AskInfo from Client1</option>
       <option label="foo">Task #3: Client2 GiveInfo to Lawyer1</option>
       <option label="foo">Task #4: Client1 GiveInfo to Lawyer2</option>
       </select>
       </td>
       <td><input type="radio" name="is">Is</input><br><input type="radio" name="is">Is not</input></td>
      <td>
      <select>
       <option label="foo">Disabled</option>
       <option label="foo">Active</option>
       <option label="foo">Failed</option>
       <option label="foo">Succeeded</option>
       </select>
</td>
    </tr>
  <tr>
    <td><input type="radio" name="is">and</input><br><input type="radio" name="is">or</input></td>
    <td>
      <select>
       <option label="foo">Task #1: Lawyer1 AskInfo from Client2</option>
       <option label="foo">Task #2: Lawyer2 AskInfo from Client1</option>
       <option label="foo">Task #3: Client2 GiveInfo to Lawyer1</option>
       <option label="foo">Task #4: Client1 GiveInfo to Lawyer2</option>
       </select>
       </td>
       <td><input type="radio" name="is">Is</input><br><input type="radio" name="is">Is not</input></td>
      <td>
      <select>
       <option label="foo">Disabled</option>
       <option label="foo">Active</option>
       <option label="foo">Failed</option>
       <option label="foo">Succeeded</option>
       </select>
</td>
    </tr>
  <tr>
    <td><input type="radio" name="is">and</input><br><input type="radio" name="is">or</input></td>
    <td>
      <select>
       <option label="foo">Counter: Task_1_Completion_counter</option>
       <option label="foo">Counter: Task_2_Completion_counter</option>
       </select>
       </td>
       <td><input type="radio" name="is">&gt;</input><br>
       <input type="radio" name="is">&gt;=</input><br>
       <input type="radio" name="is">=</input><br>
       <input type="radio" name="is">!=</input><br>
       <input type="radio" name="is">&lt;=</input><br>
       <input type="radio" name="is">&lt;</input><br>
      <td>
      <input type="text" size="3">
</td>
    </tr>

</table>
<li>(B priority): additional recipients
<li><b>Timeout</b>:  At <input type="text" size="10"> duration after being enabled, task changes to state:
      <select>
       <option label="foo">Disabled</option>
       <option label="foo">Failed</option>
       <option label="foo">Succeeded</option>
       </select>
<li><b>Repetitions</b>.  This task can be completed up to <input type="text" size="2"> times.
<li><b>Rating</b>.  Recipient (?) is given a list of choices to rate an
input.  Choices of choices: Pass/fail, letter grade, numeric grade.
</ul>

