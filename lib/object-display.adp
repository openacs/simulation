<if @simplay@>
<master src="/packages/simulation/www/simplay/play-master">
</if>
<else>
<master src="/packages/simulation/www/normal-master" />
</else>
  <property name="title">@page_title;noquote@</property>
  <property name="context">@context;noquote@</property>

<if @content_html@ not nil>@content_html;noquote@</if>

<if @simplay@ not true>
  <if @edit_url@ not nil>
    <p>
      <a href="@edit_url@" class="button">#simulation.Edit#</a>
    </p>
  </if>
</if>

<if @simplay@>
  <if @recipient_p@>
    <p>
    <a href="@message_url@">#simulation.Send_a_message_to# @page_title@</a>
    </p>
  </if>
</if>