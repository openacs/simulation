<master src="/packages/simulation/www/simulation-master">
  <property name="title">@page_title;noquote@</property>
  <property name="context">@context;noquote@</property>
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

<formtemplate id="simulation"></formtemplate>
<p>TODO: implement invitations.
<p>TODO: When switching from open enrollment to "by invitation only" and back, the dates are lost -- see if we can avoid that.
