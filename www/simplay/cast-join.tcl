ad_page_contract {
    This script will cast a user in a simulation case. If role id is provided
    the user will be cast in that role. If case_id is not provided a new case
    will be created.

    @author Peter Marklund
} {
    {workflow_id:integer ""}
    {case_id:integer ""}
    {role_id:integer ""}
}

# We need either case_id or workflow_id
if { [empty_string_p $workflow_id] && [empty_string_p $case_id] } {
    ad_return_error "Missing parameters" \
    [_ simulation.lt_Either_of_the_HTTP_pa]
    ad_script_abort
}

# Get simulation info
if { [empty_string_p $workflow_id] } {
    simulation::case::get -case_id $case_id -array case
    set workflow_id $case(workflow_id)
}
simulation::template::get -workflow_id $workflow_id -array simulation

# We require the user to be enrolled
auth::require_login
set user_id [ad_conn user_id]
set enrolled_p [simulation::template::user_enrolled_p \
               -workflow_id $workflow_id]
# Begin a series of checks and abort with an error message on the
# first failure
if { !$enrolled_p } {
        ad_return_forbidden \
                [_ simulation.lt_Not_enrolled_in_simul] \
                [_ simulation.lt_blockquoteWe_are_sorr]
        ad_script_abort
}

if { ![empty_string_p $role_id] } {
    # Role id specified so cast to that role

    # Check that user is allowed to cast himself in a role
    if { ![string equal $simulation(casting_type) "open"] } {
        ad_return_forbidden \
                [_ simulation.lt_Cannot_choose_role_in] \
                [_ simulation.lt_blockquoteWe_are_sorr_1]
        ad_script_abort
    }

    # Check that there are empty spaces in the role
    set max_n_users [simulation::role::get_element -role_id $role_id -element users_per_case]
    set n_users [llength [workflow::case::role::get_assignees -case_id $case_id -role_id $role_id]]
    set n_empty_spots [expr $max_n_users - $n_users]
    if { $n_empty_spots <= "0" } {
        simulation::role::get -role_id $role_id -array role
        ad_return_forbidden \
                [_ simulation.lt_No_empty_slots_in_rol] \
                [_ simulation.lt_blockquoteWe_are_sorr_2]
        ad_script_abort        
    }

    # Check that the user is in a group mapped to the role
    if { ![simulation::template::user_mapped_to_role_p -workflow_id $workflow_id -role_id $role_id] } {
        simulation::role::get -role_id $role_id -array role
        ad_return_forbidden \
                [_ simulation.lt_Not_allowed_to_cast_i] \
                [_ simulation.lt_blockquoteWe_are_sorr_3]
        ad_script_abort
    }
} else {
    # No role id specified

    if { [string equal $simulation(casting_type) "auto"] } {
        ad_return_forbidden \
                [_ simulation.lt_Cannot_choose_case_in] \
                [_ simulation.lt_blockquoteWe_are_sorr_4]
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

    # Find the first role with empty slots and that is mapped
    # to a group the user is a member of
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
          and exists (select 1
                      from sim_role_party_map srpm,
                           party_approved_member_map pamm
                      where srpm.party_id = pamm.party_id
                        and pamm.member_id = :user_id
                        and srpm.role_id = wr.role_id
                      )
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
        ad_return_error [_ simulation.No_available_roles] \
                        [_ simulation.lt_We_couldnt_find_any_r]
        ad_script_abort
    }
}

# We now know the user is authorized to cast himself and we have a role to cast
# him to so carry out the casting.

set role_short_name [workflow::role::get_element -role_id $role_id -element short_name]
set assign_array($role_short_name) [list $user_id]
workflow::case::role::assign \
    -case_id $case_id \
    -array assign_array

ad_returnredirect [export_vars -base cast { workflow_id }]
