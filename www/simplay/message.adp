<master src="play-master">
  <property name="title">@page_title;noquote@</property>
  <property name="context">@context;noquote@</property>
  <property name="focus">@focus;noquote@</property>

<if @attachment_options@ nil>
  <if @form_mode@ eq "edit">
      <p>
	#simulation.to_attach_document_to_message#
      </p>
  </if>
</if>
  
<formtemplate id="message"></formtemplate>
