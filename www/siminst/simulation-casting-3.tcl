ad_page_contract {
    The page where user groups are chosen for the different
    roles of a simulation. Part of the casting step
    in the instantiation process.

    @author Peter Marklund
} {
    workflow_id:integer
}

permission::require_write_permission -object_id $workflow_id

simulation::template::get -workflow_id $workflow_id -array sim_template

set page_title "Set user casting rules"
set context [list [list "." "SimInst"] $page_title]

set form [list]

lappend form {casting_type:text(radio)
    {label "Casting type"}
    {options {{"Participants are <b>automatically</b> assigned cases and roles" auto} {"Participants choose their own cases" group} {"Participants choose cases and roles" open}}}
    {section "Casting type"}
    {help_text "If participants have not selected groups or roles by the simulation start time, they are automatically assigned."}
}

if { [string equal $sim_template(enroll_type) "closed"] || [empty_string_p $sim_template(enroll_type)] } {
    # Closed enrollment so offer only invited or auto_enroll groups
    set eligible_groups [simulation::casting_groups -mapped_only -workflow_id $workflow_id]
} else {
    # Open enrollment, meaning anybody can sign up, so offer all subsite groups
    set eligible_groups [simulation::casting_groups -workflow_id $workflow_id]
}

set num_groups [llength $eligible_groups]

if { $num_groups == "0" } {
    return
}

foreach role_id [workflow::get_roles -workflow_id $workflow_id] {
    set role_${role_id}_pretty_name [workflow::role::get_element -role_id $role_id -element pretty_name]

    if { $num_groups > 0 } {
        lappend form [list \
                          users_per_case_${role_id}:integer \
                          [list label "Number of users for <b>\$role_${role_id}_pretty_name</b>"] \
                          {value 1} \
                          {html {size 2}} \
                          [list section "\$role_${role_id}_pretty_name"]
                     ]
    }

    lappend form [list parties_${role_id}:text(checkbox),multiple,optional \
                      [list label "Cast <b>\$role_${role_id}_pretty_name</b> only from these groups"] \
                      {options $eligible_groups} \
                      [list section "\$role_${role_id}_pretty_name"]
                     ]
}


ad_form \
    -name actors \
    -export { workflow_id } \
    -form $form \
    -on_request {
        simulation::template::get -workflow_id $workflow_id -array sim_template

        foreach elm { 
            casting_type
        } { 
            set $elm $sim_template($elm)
        }

        if { [empty_string_p $casting_type] } {
            set casting_type "auto"
        }

        simulation::template::role_party_mappings -workflow_id $workflow_id -array roles

        set all_group_ids [list]
        foreach group_item $eligible_groups {
            lappend all_group_ids [lindex $group_item 1]
        }

        foreach role_id [workflow::get_roles -workflow_id $workflow_id] {
            if { [info exists roles($role_id)] } {
                # There are groups selected in the database
                array set one_role $roles($role_id)
                element::set_values actors parties_${role_id} $one_role(parties)
                element set_properties actors users_per_case_${role_id} -value $one_role(users_per_case)
            } else {
                # There are no groups selected. Select all by default in the form.
                element::set_values actors parties_${role_id} $all_group_ids
            }
        }      


    } -on_submit {

        # Validation
        # Make sure the number of users per case does not exceed the total number of users
        # in the selected parties
        array set groups [simulation::casting_groups_with_counts -workflow_id $workflow_id]
        set error_p 0
        foreach role_id [workflow::get_roles -workflow_id $workflow_id] {
            set users_per_case [set users_per_case_$role_id]

            if { $users_per_case == "0" } {
                template::form::set_error actors users_per_case_$role_id "Number of users per case must be greater than zero"
                set error_p 1
            }

            if { [llength [set parties_$role_id]] > 0 } {
                set n_members 0
                foreach party_id [set parties_$role_id] {
                    set n_members [expr $n_members + [lindex $groups($party_id) 1]]
                }

                if { $users_per_case > $n_members } {
                    template::form::set_error actors users_per_case_$role_id "Number of users per case must not be larger than the number of users in the selected groups: $n_members"
                    set error_p 1
                } 
            } else {
                template::form::set_error actors parties_$role_id "At least one group must be selected for each role"
                set error_p 1                
            }
        }                
        if { $error_p } {
            break
        }

        db_transaction {

            set row(casting_type) $casting_type
            simulation::template::edit \
                -workflow_id $workflow_id \
                -array row

            simulation::template::delete_role_party_mappings -workflow_id $workflow_id
            foreach role_id [workflow::get_roles -workflow_id $workflow_id] {
                set role_edit(users_per_case) [set users_per_case_$role_id]
                simulation::role::edit -role_id $role_id -array role_edit
                
                simulation::template::new_role_party_mappings \
                    -role_id $role_id \
                    -parties [set parties_$role_id] \
                }
        }

        set uncast_mapped_groups [db_list uncast_mapped_groups_count "
            select g.group_name
            from sim_party_sim_map spsm,
                 groups g
            where spsm.simulation_id = :workflow_id
            and g.group_id = spsm.party_id
            and not exists (select 1
                            from sim_role_party_map srpm,
                                 workflow_roles wr
                            where srpm.role_id = wr.role_id
                              and wr.workflow_id = :workflow_id
                              and srpm.party_id = spsm.party_id
                           )
        "]
        if { [llength $uncast_mapped_groups] > 0 } {
            template::form::set_error actors parties_$role_id "The following groups are not mapped to any roles: [join $uncast_mapped_groups ", "]."
            break
        }

        simulation::template::enroll_and_invite_users -workflow_id $workflow_id

        simulation::template::flush_inst_state -workflow_id $workflow_id
        wizard forward
    }

set all_tabs_complete_p [simulation::template::ready_for_casting_p -workflow_id $workflow_id]
if { $all_tabs_complete_p } {
    wizard submit actors -buttons { back next finish }
} else {
    wizard submit actors -buttons { back next }
}
