<master src="play-master">
  <property name="title">@page_title;noquote@</property>
  <property name="context">@context;noquote@</property>
  <property name="focus">@focus;noquote@</property>

<if @attachment_options@ nil>
  <p>
    <font color="red"><em>NOTE</em></font>: To attach a document to your message you need to <a
    href="@document_upload_url@">upload a document</a> to your
    portfolio before writing the message.
  </p>
</if>
  
<formtemplate id="message"></formtemplate>

