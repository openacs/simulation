<master>
  <property name="title">@page_title;noquote@</property>
  <property name="context">@context;noquote@</property>

<if @already_cast_p@>
  <p>
    You are already cast in the following roles:
  </p>
 
  <listtemplate name="cast_info"></listtemplate></p>
  
  <p>
    Below is a listing of all roles in the simulation.
  </p>

</if>
<else>
  <p>
    Select which case <if @simulation.casting_type@ eq "open">and
    role</if> to join, or create a new case for yourself.  If you do not
    select a case <if @simulation.casting_type@ eq "open">and role</if>
    to join, you will be automatically assigned to a case <if
    @simulation.casting_type@ eq "open">and role</if> when the
    simulation begins.
  </p>

</else>

<listtemplate name="roles"></listtemplate></p>

<if @join_new_case_url@ not nil>
  <ul class="action-links">
    <li><a href="@join_new_case_url@">Be the first user in a new case</a></li>
  </ul>
</if>
