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
    #simulation.lt_You_are_doing_a_bulk#
  </p>

  <if @ignored_actions_count@ gt 0>
    <p>
      #simulation.ignoring_actions#
    </p>
  </if>
</if>

<if @message_p@ not true>
<if @documents_pre_form_empty_p@>
  <p>
    <em>#simulation.no_attachments#</em>
  </p>
</if>
<else>
  <p>
    <h4>#simulation.Documents#</h4>
    @documents_pre_form;noquote@
  </p>
</else>
</if>

<if @message_p@>
  <if @attachment_options@ nil>
    <p>
      #simulation.to_attach_a_document#
    </p>
  </if>
</if>

<if @received_attachments@ not nil>
  <p>
    #simulation.lt_Attachments_in_receiv# @received_attachments;noquote@
  </p>
</if>


<formtemplate id="@form_id@"></formtemplate>
