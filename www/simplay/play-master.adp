<master src="../simulation-master">
  <property name="title">@title;noquote@</property>
  <property name="context">@context;noquote@</property>
  <property name="header_stuff">
@header_stuff;noquote@

    <link href="css/simplay-bic.css" rel="stylesheet" type="text/css">
    <link href="css/default-master.css" rel="stylesheet" type="text/css">
    <link href="css/site-master.css" rel="stylesheet" type="text/css">
    <link href="css/forms.css" rel="stylesheet" type="text/css">
    <link href="css/lists.css" rel="stylesheet" type="text/css">
    <link href="css/simplay.css" rel="stylesheet" type="text/css">	
<style type="text/css">
#session_header {
	width: 200px;
	font-size: 80%;
	margin-top: -30px;
	margin-right: 10px;
	color: #333;
}

h1.page-title {
	margin-left: 200px;
	padding-left: 15px;
}
</style>
</property>
  <if @focus@ not nil><property name="focus">@focus;noquote@</property></if>

<h4 id="session_header">#simulation.Session#: @simulation_title;noquote@</h4>
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