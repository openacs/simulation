<master>
  <property name="title">@title;noquote@</property>
  <property name="context">@context;noquote@</property>

  <table class="list" cellpadding="3" cellspacing="1">
      <tr class="list-header">
          <th class="list">
              Case #
          </th>
          <th class="list" align="right">
              Current Users
          </th>
          <th class="list" align="right">
          </th>
      </tr>
                <tr class="list-odd">
                <td class="list">
                  Case #1
                </td>
                <td class="list" align="right">
                  Bob
                  <br>______
                </td>
                <td class="list" align="right">
                <input type="submit" value="Join">
                </td>
            </tr>
                <tr class="list-even">
                <td class="list">
                  Case #2
                </td>
                <td class="list" align="right">
                  Lokman
                  <br>Peter
                </td>
                <td class="list" align="right">
                </td>
            </tr>
                <tr class="list-odd">
                <td colspan="3" class="list" align="right">
                  <bR><input type="submit" value="Be the first user in
      a new case">
                </td>
            </tr>
  </table>

If no rows, display this text: "There are no cases yet."
<p>
After clicking join, redirect back to this page.  Hide all buttons.
Show new text at the bottom: "You are participating in this simulation
as a player in case #X.  Your role will be determined when the
simulation begins.  The simulation will start XXX."