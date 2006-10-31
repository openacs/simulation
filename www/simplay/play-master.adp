<master src="../simulation-master">
  <property name="title">@title;noquote@</property>
  <property name="context">@context;noquote@</property>
  <property name="header_stuff">
@header_stuff;noquote@

<link rel="stylesheet" type="text/css" href="/resources/simulation/simplay.css" media="all" />

@extra_css;noquote@

</property>

  <if @focus@ not nil><property name="focus">@focus;noquote@</property></if>

<h4 id="session_header">#simulation.Session#: @simulation_title;noquote@</h4>
<div id="play-container">
  <div id="play-content">
    <div id="inner-content">
      <slave>
    </div>
  </div>
  <div id="control-bar">
    <include src="control-bar" case_id="@case_id@" role_id="@role_id@">
  </div>


</div>
<hr id="clearer" />
