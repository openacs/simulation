ad_page_contract {
    The page for mapping roles of a simulation template
    to characters in the CityBuild world. First page
    of the mapping step.

    @author Peter Marklund
} {
    workflow_id:integer
}

set page_title "Map to Characters"
set context [list [list "." "SimInst"] $page_title]

# Loop over all workflow roles and add a character select widget for each
set form [list]
set character_options [simulation::get_object_options -content_type sim_character]
foreach role_id [workflow::get_roles -workflow_id $workflow_id] {
    set role_short_name [workflow::role::get_element -role_id $role_id -element short_name]
    set role_pretty_name [workflow::role::get_element -role_id $role_id -element pretty_name]
    lappend form [list role_${role_short_name}:text(select) \
                      [list label $role_pretty_name] \
                      [list options $character_options]
                 ]
}

ad_form \
    -name characters \
    -export { workflow_id } \
    -form $form \
    -on_submit {

        db_transaction {
            # Create a new template that is clone of the existing one
            set workflow_id [simulation::template::clone -workflow_id $workflow_id]

            # Map each role to chosen character
            foreach role_id [workflow::get_roles -workflow_id $workflow_id] {
                set role_short_name [workflow::role::get_element -role_id $role_id -element short_name]
                simulation::role::edit -role_id $role_id -character_id [set role_${role_short_name}]
            }
        }

        # Proceed to the task page
        ad_returnredirect [export_vars -base map-tasks {workflow_id}]
        ad_script_abort
    }
