<if @bulk_p@>
  <master src="/packages/simulation/www/simulation-master">
</if>
<else>
  <master src="play-master">
  <property name="case_id">@case_id@</property>
</else>
  <property name="title">@page_title;noquote@</property>
  <property name="context">@context;noquote@</property>
  <property name="focus">@focus;noquote@</property>

<if @bulk_p@>
  <p>
    You are doing a bulk response to @common_actions_count@ tasks.
  </p>

  <if @ignored_actions_count@ gt 0>
    <p>
      <strong>Note:</strong> Ignoring @ignored_actions_count@ tasks that don't have the task
      name "@action.pretty_name@". Please back up your browser if you
      want to change the selection of tasks.
    </p>
  </if>
</if>

<p>
@action.description@
</p>

<p>
@documents_pre_form;noquote@
</p>

<formtemplate id="@form_id@"></formtemplate>
