<master>
  <property name="title">@page_title;noquote@</property>
  <property name="context">@context;noquote@</property>

<if @already_cast_p@>
  <p>
    #simulation.lt_You_are_already_cast_#
  </p>
 
  <listtemplate name="cast_info"></listtemplate></p>
  
  <p>
    #simulation.lt_Below_is_a_listing_of#
  </p>

</if>
<else>
  <p>
    <if @simulation.casting_type@ eq "open">

    #simulation.lt_Select_which_case_and_role_to_join#

    </if>
    <else>

    #simulation.lt_Select_which_case_to_join#

    </else>
  </p>

</else>

<listtemplate name="roles"></listtemplate></p>

<if @join_new_case_url@ not nil>
  <ul class="action-links">
    <li><a href="@join_new_case_url@">#simulation.lt_Be_the_first_user_in_#</a></li>
  </ul>
</if>

