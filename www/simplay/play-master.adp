<master src="../simulation-master">
  <property name="title">@title;noquote@</property>
  <property name="context">@context;noquote@</property>
  <property name="header_stuff">@header_stuff;noquote@</property>
  <if @focus@ not nil><property name="focus">@focus;noquote@</property></if>

<table border="0" width="100%">
  <tr>
    <td valign="top" width="200">
      <include src="control-bar" case_id="@case_id@" role_id="@role_id@">
    </td>
    <td valign="top">
      <slave>
    </td>
  </tr>
</table>

