<master src="../simulation-master">
  <property name="title">@title;noquote@</property>
  <property name="context">@context;noquote@</property>
  <if @focus@ not nil><property name="focus">@focus;noquote@</property></if>

<table border="0" width="100%">
  <tr>
    <td valign="top">
      <include src="control-bar" case_id="@case_id@">
    </td>
    <td valign="top">
      <slave>
    </td>
  </tr>
</table>

