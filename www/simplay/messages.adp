<master src="play-master">
  <property name="title">@title;noquote@</property>
  <property name="context">@context;noquote@</property>

<include src="/packages/simulation/lib/messages" user_id="@user_id@" case_id="@case_id@"></include>

<p>TODO: show sent messages as well
<p>TODO: automatically create a Notification entry for each user per
role, and show an add/remove link here