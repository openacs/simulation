<master>
  <property name="title">@title;noquote@</property>
  <property name="context">@context;noquote@</property>

<p>Select a case (if casting type=group, then say, "and role") to join, or create a new case for yourself.  If you do not select a case to join, you will be automatically
      assigned a case (... and role)
      when the simulation begins.

  <table class="list" cellpadding="3" cellspacing="1">
      <tr class="list-header">
          <th class="list">
              Case #
          </th>
          <th class="list" align="right">
              Role
          </th>
          <th class="list" align="right">
              Current Users
          </th>
          <th class="list" align="right">
              Available<br>Slots
          </th>
          <th class="list" align="right">
          </th>
      </tr>
                <tr class="list-odd">
                <td class="list" rowspan="2">
                  Case #1
                </td>
                <td class="list">
                  Lawyer for Defendant
                </td>
                <td class="list" align="right">
                  Bob
                </td>
                <td class="list" align="right">
                1
                </td>
                <td class="list" align="right">
                <input type="submit" value="Join">
                </td>
            </tr>
                <tr class="list-even">
                <td class="list">
                  Lawyer for Plaintiff
                </td>
                <td class="list" align="right">
                Jeroen
                <br>Philip
                <br>Elvis
                </td>
                <td class="list" align="right">
                FULL
                </td>
                <td class="list" align="right">
                </td>
            </tr>
                <tr class="list-odd">
                <td class="list" rowspan="2">
                  Case #2
                </td>
                <td class="list">
                  Lawyer for Defendant
                </td>
                <td class="list" align="right">
                  Bob
                </td>
                <td class="list" align="right">
                1
                </td>
                <td class="list" align="right">
                <input type="submit" value="Join">
                </td>
            </tr>
                <tr class="list-even">
                <td class="list">
                  Lawyer for Plaintiff
                </td>
                <td class="list" align="right">
                <i>empty</i>
                </td>
                <td class="list" align="right">
                3
                </td>
                <td class="list" align="right">
                <input type="submit" value="Join">
                </td>
            </tr>
</table>
<bR><input type="submit" value="Be the first user in
      a new case">
<p>
If no rows, display this text: "There are no cases yet."
<p>
After clicking join, redirect back to this page.  Hide all buttons.
Show new text at the bottom: "You are participating in this simulation
as a player in case #X.  The simulation will start XXX."
<p>If casting type is group instead of open, do not display or group
by the role column.