<master src="/packages/simulation/www/simulation-master">
  <property name="title">@page_title;noquote@</property>
  <property name="context">@context;noquote@</property>
  <property name="focus">object.title</property>
  <property name="header_stuff">
    <script language="javascript">
        function FormRefresh(form_name) {
            if (document.forms == null) return;
            if (document.forms[form_name] == null) return;
            if (document.forms[form_name].elements["__refreshing_p"] == null) return;

            document.forms[form_name].elements["__refreshing_p"].value = 1;
            document.forms[form_name].submit();
        }
        function CopyText(text) {
            if (document.all) {
                holdtext.innerText = text;
                Copied = holdtext.createTextRange();
                Copied.execCommand("Copy");
            } else if (window.netscape) {
                netscape.security.PrivilegeManager.enablePrivilege('UniversalXPConnect');

                var clip = Components.classes['@mozilla.org/widget/clipboard;1'].createInstance(Components.interfaces.nsIClipboard);
                if (!clip) return;

                var trans = Components.classes['@mozilla.org/widget/transferable;1'].createInstance(Components.interfaces.nsITransferable);
                if (!trans) return;

                trans.addDataFlavor('text/unicode');

                var str = new Object();
                var len = new Object();

                var str = Components.classes["@mozilla.org/supports-string;1"].createInstance(Components.interfaces.nsISupportsString);

                var copytext = text;

                str.data = copytext;

                trans.setTransferData("text/unicode", str, copytext. length*2);

                var clipid = Components.interfaces.nsIClipboard;
                if (!clipid) return false;

                clip.setData(trans, null, clipid. kGlobalClipboard);
            }
        }
    </script>
    <textarea id="holdtext" style="display: none;"></textarea>
  </property>

<formtemplate id="object"></formtemplate>
TODO: Show on map should be read-only unless user has "sim_set_map_p"
priv on package_id