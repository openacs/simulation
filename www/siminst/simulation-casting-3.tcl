ad_page_contract {
    The page where actors are chosen for the different
    roles of a simulation. Part of the casting step
    in the instantiation process.

    @author Peter Marklund
} {
    workflow_id:integer
}

set page_title "Choose actors"
set context [list [list "." "SimInst"] $page_title]

# Loop over all workflow roles and append the actor and "in groups of" widgets to the form
set form [list]

set eligible_groups [simulation::groups_eligible_for_casting]

foreach role_id [workflow::get_roles -workflow_id $workflow_id] {
    set role_pretty_name [workflow::role::get_element -role_id $role_id -element pretty_name]
    lappend form [list actor_${role_id}:text(select) \
                      [list label $role_pretty_name] \
                      [list options $eligible_groups]
                 ]
    lappend form [list group_${role_id}:integer [list label "In groups of"] [list value 1]]
}

ad_form \
    -name actors \
    -export { workflow_id } \
    -form $form \
    -on_request {
        db_foreach select_group_mappings {
            select role_id,
            party_id,
            group_size
            from sim_role_group_map
            where role_id in (select role_id
                              from workflow_roles
                              where workflow_id = :workflow_id
                              )
        } {
            element set_properties actors actor_${role_id} -value $party_id
            element set_properties actors group_${role_id} -value $group_size    
        }      
    } -on_submit {

        # TODO: move this code into the simulation::template::edit proc? Low priority.

        # Clear out old mappings
        db_dml clear_old_group_mappings {
            delete from sim_role_group_map
            where role_id in (select role_id
                              from workflow_roles
                              where workflow_id = :workflow_id
                              )
        }

        foreach role_id [workflow::get_roles -workflow_id $workflow_id] {
            simulation::template::map_group_to_role \
                -role_id $role_id \
                -group_id [set actor_$role_id] \
                -group_size [set group_$role_id]
        }

        ad_returnredirect .
        ad_script_abort
    }
