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
                @roles.case_pretty@ <if @roles.join_case_url@ ne ""><font size="-1">\[\<a href="@roles.join_case_url@">join case</a>]</font></if>
            }
        }
        role_name {
            label "Role"
        }
        user_name {
            label "User"
        }
    }

db_multirow -extend { join_case_url join_role_url } roles select_case_info {
    select wc.case_id,
           sc.label as case_pretty,
           cu.first_names || ' ' || cu.last_name as user_name,
           wr.pretty_name as role_name
    from workflow_cases wc,
         sim_cases sc,
         workflow_case_role_party_map wcrpm,
         workflow_roles wr,
         cc_users cu
    where wc.object_id = sc.sim_case_id
      and wc.workflow_id = :workflow_id
      and wcrpm.case_id = wc.case_id
      and wcrpm.party_id = cu.user_id
      and wr.role_id = wcrpm.role_id
      order by sc.label, wr.pretty_name, cu.last_name
} {
    set join_case_url ""
    set join_role_url ""

    if { !$already_cast_p } {
        if { [string equal $simulation(casting_type) "group"] } {
            set join_case_url [export_vars -base cast-join { case_id }]
        } else {
            set join_role_url [export_vars -base cast-join { case_id role_id }]
        }
    }
}

if { !$already_cast_p } {
    set join_new_case_url [export_vars -base cast-join { workflow_id }]
}
