<master>
  <property name="title">@page_title;noquote@</property>
  <property name="context">@context;noquote@</property>

<if @already_cast_p@>
  <p>
    You are already cast in the following roles:
  </p>
 
  <listtemplate name="cast_info"></listtemplate></p>
  
  <p>
    Below is a listing of all users in the simulation.
  </p>

</if>
<else>
  <p>
    Select which case <if @simulation.casting_type@ eq "open">and
    role</if> to join, or create a new case for yourself.  If you do not
    select a case <if @simulation.casting_type@ eq "open">and role</if>
    to join, you will be automatically assigned to a case <if
    @simulation.casting_type@ eq "open">and role</if> when the
    simulation begins.
  </p>

</else>

<listtemplate name="roles"></listtemplate></p>

<if @join_new_case_url@ not nil>
  <p>
    <a href="@join_new_case_url@" class="action">Be the first user in a new case</a>
  </p>
</if>


<p>
&nbsp;
</p>
<p>
&nbsp;
</p>
<p>
&nbsp;
</p>
<p>
&nbsp;
</p>
<p>
Mockup below:
</p>

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
TODO: If casting type is group instead of open, do not display or group
by the role column.
