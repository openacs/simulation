ad_page_contract {
    Page allows users to cast themselves in simulations with casting type open or group.
    For casting type group the user can only choose the case to be in. If casting type
    is open he/she can also choose role.

    @author Peter Marklund
} {
    workflow_id:integer
}

auth::require_login
set user_id [ad_conn user_id]
set package_id [ad_conn package_id]
simulation::template::get -workflow_id $workflow_id -array simulation

# Check user is enrolled
set enrolled_p [simulation::template::user_enrolled_p -workflow_id $workflow_id]
if { !$enrolled_p } {
    set enroll_now_text ""
    if { [string equal $simulation(enroll_type) "open"] } {
        set enroll_now_text "<a href=\"[export_vars -base enroll { workflow_id }]\">Click here</a> to enroll now."
    }

        ad_return_forbidden \
                "Not enrolled in simulation \"$simulation(pretty_name)\"" \
                "<blockquote>
  We are sorry, but since you are not enrolled in simulation \"$simulation(pretty_name)\" you can not choose case or role in it. $enroll_now_text
</blockquote>"
        ad_script_abort
}

# Check self casting is allowed
if { [string equal $simulation(casting_type) "auto"] } {
        ad_return_forbidden \
                "You will be automatically cast in \"$simulation(pretty_name)\"" \
                "<blockquote>
The simulation \"$simulation(pretty_name)\" is configured to use automatic casting. This means that a simulation case and simulation role will be chosen
automatically for you right before the simulation starts. You will be notified by email. 

<p>
  Thank you!
</p>
</blockquote>"
        ad_script_abort    
}

template::list::create \
    -name cast_info \
    -multirow cast_info \
    -no_data "You are not cast in any roles yet" \
    -elements {
        case_name {
            label "Case"
        }
        role_name {
            label "Role"
        }
    }

db_multirow cast_info cast_info {
    select sc.label as case_name,
           wr.pretty_name as role_name
    from workflow_case_role_party_map wcrpm,
         workflow_cases wc,
         sim_cases sc,
         workflow_roles wr
    where wcrpm.party_id = :user_id
      and wcrpm.case_id = wc.case_id
      and wc.workflow_id = :workflow_id
      and wc.object_id = sc.sim_case_id
      and wr.role_id = wcrpm.role_id
}

set already_cast_p [expr ${cast_info:rowcount} > 0]

if { !$already_cast_p } {
    set page_title "Join a Case in Simulation \"$simulation(pretty_name)\""
} else {
    set page_title "User castings in simulation \"$simulation(pretty_name)\""
}
set context [list [list "." "SimPlay"] $page_title]


template::list::create \
    -name roles \
    -multirow roles \
    -no_data "There are no cases in this simulation yet" \
    -elements {
        case_pretty {
            label "Case"
            display_template {
                @roles.case_pretty@ <if @roles.can_join_case_p@ and @roles.join_case_url@ ne ""><font size="-1">\[\<a href="@roles.join_case_url@">join case</a>]</font></if>
            }
        }
        role_name {
            label "Role"
            display_template {
                @roles.role_name@ <if @roles.can_join_role_p@ and @roles.join_role_url@ ne ""><font size="-1">\[\<a href="@roles.join_role_url@">join role</a>]</font></if>
            }
        }
        n_users {
            label "# Users"
        }
        max_n_users {
            label "Max # users"
        }
    }

db_multirow -extend { can_join_role_p join_case_url join_role_url } roles select_case_info {
    select wc.case_id,
           wr.role_id,
           sc.label as case_pretty,
           wr.pretty_name as role_name,
           sr.users_per_case as max_n_users,
           (select count(*)
            from workflow_case_role_party_map wcrpm2
            where wcrpm2.case_id = wc.case_id
            and wcrpm2.role_id = wr.role_id
           ) as n_users,
           (select count(*)
            from sim_role_party_map srpm,
                 party_approved_member_map pamm
            where srpm.party_id = pamm.party_id
              and pamm.member_id = :user_id
              and srpm.role_id = wr.role_id
           ) as is_mapped_p    
    from workflow_cases wc,
         sim_cases sc,
         workflow_roles wr,
         sim_roles sr
    where wc.object_id = sc.sim_case_id
      and wc.workflow_id = :workflow_id
      and wr.role_id = sr.role_id
      and wr.workflow_id = :workflow_id
      order by sc.label, wr.pretty_name
} {
    # User can join a case if there is at least one role in the case that the user can join
    # User can join a role if he is in a group mapped to the role and there are empty spots for the role    
    if { $is_mapped_p && [expr $max_n_users - $n_users] > 0 } {
        set can_join_role_p 1
        set can_join_case_p_array($case_id) 1
    } else {
        set can_join_role_p 0
        if { ![info exists can_join_case_p_array($case_id)] } {
            set can_join_case_p_array($case_id) 0
        }
    }

    set join_case_url ""
    set join_role_url ""

    if { !$already_cast_p } {
        if { [string equal $simulation(casting_type) "group"] } {
            # Group casting - cast to case
            set join_case_url [export_vars -base cast-join { case_id }]
        } else {
            # Open casting - cast to role
            set join_role_url [export_vars -base cast-join { case_id role_id }]
        }
    }
}

template::multirow extend roles can_join_case_p
template::multirow foreach roles {
    if { $can_join_case_p_array($case_id)} {
        set can_join_case_p 1
    }
}

if { !$already_cast_p } {
    set join_new_case_url [export_vars -base cast-join { workflow_id }]
}

