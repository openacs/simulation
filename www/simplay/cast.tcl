ad_page_contract {
    This page allows users to choose which group to join.  It is only relevant for simulations with casting type of group.
} {
    {workflow_id:integer ""}
}

auth::require_login
set user_id [ad_conn user_id]
set package_id [ad_conn package_id]
simulation::template::get -workflow_id $workflow_id -array simulation

set page_title "Join a Case in Simulation SIMNAME"
set context [list [list "." "SimPlay"] $page_title]

set enrolled_p [simulation::template::user_enrolled_p -workflow_id $workflow_id]
if { !$enrolled_p } {
        ad_return_forbidden \
                "Not enrolled in simulation \"$simulation(pretty_name)\"" \
                "<blockquote>
  We are sorry, but since you are not enrolled in simulation \"$simulation(pretty_name)\" you can not choose case or role in it.
</blockquote>"
        ad_script_abort
}

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
    -name roles \
    -multirow roles \
    -no_data "There are no cases in this simulation yet" \
    -elements {
        case_pretty {
            label "Case"
        }
    }

db_multirow -extend { join_url } roles select_case_info {
    select sc.label as case_pretty
    from workflow_cases wc,
         sim_cases sc
    where wc.case_id = sc.sim_case_id
      and wc.workflow_id = :workflow_id
} {
    set join_url [export_vars -base cast-join { case_id role_id }]
}
