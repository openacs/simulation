ad_page_contract {
    The page where actors are chosen for the different
    roles of a simulation. Part of the casting step
    in the instantiation process.

    @author Peter Marklund
} {
    workflow_id:integer
}

set page_title "Set user casting rules"
set context [list [list "." "SimInst"] $page_title]

set form [list]

set eligible_groups [simulation::casting_groups -enrolled_only -workflow_id $workflow_id]

set pick_groups_url [export_vars -base simulation-casting-2 { workflow_id }]

foreach role_id [workflow::get_roles -workflow_id $workflow_id] {
    set role_${role_id}_pretty_name [workflow::role::get_element -role_id $role_id -element pretty_name]

    lappend form [list parties_${role_id}:text(checkbox),multiple,optional \
                      [list help_text "Only users in these groups can be cast in this role"] \
                      [list label \$role_${role_id}_pretty_name] \
                      [list options $eligible_groups]
                 ]
    lappend form [list users_per_case_${role_id}:integer [list label "Target number of users for this role per case"] [list value 1] [list html {size 2}]]
}

ad_form \
    -name actors \
    -export { workflow_id } \
    -form $form \
    -on_request {
        simulation::template::role_party_mappings -workflow_id $workflow_id -array roles

        foreach role_id [array names roles] {
            array set one_role $roles($role_id)

            element::set_values actors parties_${role_id} $one_role(parties)
            element set_properties actors users_per_case_${role_id} -value $one_role(users_per_case)
        }      
    } -on_submit {

        # Validation
        # Make sure the number of users per case does not exceed the total number of users
        # in the selected parties
        array set groups [simulation::casting_groups_with_counts -enrolled_only -workflow_id $workflow_id]
        set error_p 0
        foreach role_id [workflow::get_roles -workflow_id $workflow_id] {
            set users_per_case [set users_per_case_$role_id]

            set n_members 0
            foreach party_id [set parties_$role_id] {
                set n_members [expr $n_members + [lindex $groups($party_id) 1]]
            }

            if { $users_per_case > $n_members } {
                template::form::set_error actors users_per_case_$role_id "Number of users per case is larger than the number of users in the selected groups: $n_members"
                set error_p 1
                break
            }
        }        
        if { $error_p } {
            break
        }

        simulation::template::delete_role_party_mappings -workflow_id $workflow_id
        foreach role_id [workflow::get_roles -workflow_id $workflow_id] {
            set role_edit(users_per_case) [set users_per_case_$role_id]
            simulation::role::edit -role_id $role_id -array role_edit
            
            simulation::template::new_role_party_mappings \
                -role_id $role_id \
                -parties [set parties_$role_id] \
        }

        wizard forward
    }

wizard submit actors -buttons { back next }

