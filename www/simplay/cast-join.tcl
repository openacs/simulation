ad_page_contract {
    This script will cast a user in a simulation case. If role id is provided the user
    will be cast in that role. 

    @author Peter Marklund
} {
    {workflow_id:integer ""}
    {case_id:integer ""}
    {role_id:integer ""}
}

# We need either case_id or workflow_id
if { [empty_string_p $workflow_id] && [empty_string_p $case_id] } {
    ad_return_error "Missing parameters" "Either of the HTTP parameters workflow_id and case_id must be provided. Please contact the system administrator about this error."
    ad_script_abort
}

# Get simulation info
if { [empty_string_p $workflow_id] } {
    workflow::case::get -case_id $case_id -array case
    set workflow_id $case(workflow_id)
}
simulation::template::get -workflow_id $workflow_id -array simulation

# We require the user to be enrolled
auth::require_login
set user_id [ad_conn user_id]
set enrolled_p [simulation::template::user_enrolled_p -workflow_id $workflow_id]
if { !$enrolled_p } {
        ad_return_forbidden \
                "Not enrolled in simulation \"$simulation(pretty_name)\"" \
                "<blockquote>
  We are sorry, but since you are not enrolled in simulation \"$simulation(pretty_name)\" you can not choose case or role in it.
</blockquote>"
        ad_script_abort
}

if { ![empty_string_p $role_id] } {
    # Role id specified so cast to that role
    
    if { ![string equal $simulation(casting_type) "open"] } {
        ad_return_forbidden \
                "Cannot choose role in \"$simulation(pretty_name)\"" \
                "<blockquote>
  We are sorry, but simulation \"$simulation(pretty_name)\" does not allow users to choose role (casting type is not open). This message means the system is not operating correctly. Please contact the system administrator.

Thank you!
</blockquote>"
        ad_script_abort
    }

    # TODO: Check the max number of users for the role?

} else {
    # No role id specified

    if { [string equal $simulation(casting_type) "auto"] } {
        ad_return_forbidden \
                "Cannot choose case in \"$simulation(pretty_name)\"" \
                "<blockquote>
  We are sorry, but simulation \"$simulation(pretty_name)\" does not allow users to choose case (casting type is auto). This message means the system is not operating correctly. Please contact the system administrator.

Thank you!
</blockquote>"
        ad_script_abort
    }

    if { [empty_string_p $case_id] } {
        # Create a new case
        set current_n_cases [db_string current_n_cases {
            select count(*)
            from workflow_cases
            where workflow_id = :workflow_id
        }]
        set sim_case_id [simulation::case::new \
                             -workflow_id $workflow_id \
                             -label "Case \#[expr $current_n_cases + 1]"]
        set workflow_short_name [workflow::get_element -workflow_id $workflow_id -element short_name]
        set case_id [workflow::case::get_id \
                         -object_id $sim_case_id \
                         -workflow_short_name $workflow_short_name]
    }

    # Cast the user in the role with the most empty spaces.
    # TODO: check for no empty spaces?
    db_foreach role_with_most_empty_spaces {
        select wr.role_id,
               sr.users_per_case as max_n_users,
               (select count(*)
                from workflow_case_role_party_map wcrpm
                where wcrpm.case_id = :case_id
                  and wcrpm.role_id = wr.role_id
                ) as n_users
        from workflow_roles wr,
             sim_roles sr
        where wr.workflow_id = :workflow_id
          and wr.role_id = sr.role_id
    } {
        set n_empty_spots [expr $max_n_users - $n_users]
        if { [expr $n_empty_spots <= 0] } {
            continue
        } else {
            break
        }
    }

    if { [empty_string_p $role_id] } {
        # We weren't able to find a role with empty slots
        # TODO: what do we do now?
        ad_return_error "No available roles" "We couldn't find any roles that you could join in the selected case (case_id=$case_id) in simulation $simulation(pretty_name). You would need to join a new case. Select your administrator if you have questions.

Thank you!"
        ad_script_abort
    }
}

# We now know the user is authorized to cast himself and we have a role to cast him to
# so carry out the casting.
set role_short_name [workflow::role::get_element -role_id $role_id -element short_name]
set role_array($role_short_name) [list $user_id]
workflow::case::role::assign \
    -case_id $case_id \
    -array role_array

ad_returnredirect [export_vars -base cast { workflow_id }]
