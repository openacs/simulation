<master src="/packages/simulation/www/simulation-master">
  <property name="title">@page_title;noquote@</property>
  <property name="context">@context;noquote@</property>

<formtemplate id="actors"></formtemplate>

<p>
TODO: get desired layout, see below:
</p>

<center>
(this is just a mockup)
<table width="60%">
<tr><th>Role</th><th>Actor(s)</th><th>In groups of</th></tr>
<tr><td>Plaintiff</td>
<td><select>
  <option>Automatic Agent</option>
  <option>Student</option>
  <option>TA</option>
  <option>Professor</option>
</select>
</td>
<td><input type="text" size="2" value="1"></input>
</select>
</td>
</tr>
<tr><td>Defendent</td>
<td><select>
  <option>Automatic Agent</option>
  <option>Student</option>
  <option>TA</option>
  <option>Professor</option>
</select>
</td>
<td><input type="text" size="2" value="1"></input>
</td>
</tr>
<tr><td>Judge</td>
<td><select>
  <option>Student</option>
  <option>TA</option>
  <option>Professor</option>
</select>
</td>
<td><input type="text" size="2" value="1"></input>
</td>
</tr>
</table>
</center>


<p>
  <a href="cast-complete?workflow_id=@workflow_id@">Instantiate</a>
</p>
