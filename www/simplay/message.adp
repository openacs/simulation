<master src="play-master">
  <property name="title">@page_title;noquote@</property>
  <property name="context">@context;noquote@</property>
  <property name="focus">@focus;noquote@</property>
  <property name="header_stuff">
    <script language="javascript">
        function FormRefresh(form_name) {
            if (document.forms == null) return;
            if (document.forms[form_name] == null) return;
            if (document.forms[form_name].elements["__refreshing_p"] == null) return;

            document.forms[form_name].elements["__refreshing_p"].value = 1;
            document.forms[form_name].submit();
        }
    </script>
  </property>
  
<formtemplate id="message"></formtemplate>
<p>TODO: Task should be part of heading
<p>TODO: description and "document"
link should be inline before the message form instead of being part of
the form
<p>TODO: B: If there's only one possible recipient, don't show the
checkbox 
<p>TODO: fix problem that To: is blank in view mode
<p>TODO: make attachments be read-only links in display mode, instead
of showing checkboxes
