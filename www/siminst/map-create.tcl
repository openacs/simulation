ad_page_contract {
    A page that creates a mapped template by cloning a ready template.
    This is the first step in the mapping process.

    @author Peter Marklund
} {
    workflow_id:integer
}

set user_id [auth::require_login]

set page_title "Create Simulation from Template"
set context [list [list "." "SimInst"] $page_title]
set old_name [workflow::get_element -workflow_id $workflow_id -element pretty_name]
acs_user::get -user_id $user_id -array user_array

set name_default "New Simulation from template $old_name"

ad_form \
    -name template \
    -export { workflow_id } \
    -form {
        {pretty_name:text
            {label "Template name"}
            {value $name_default}
            {html {size 50}}
        }
    } -on_submit {
        # Create a new template that is clone of the existing one

        set new_workflow_array(pretty_name) $pretty_name
        set new_workflow_array(short_name) {}
        set new_workflow_array(sim_type) "dev_sim"
        
        set workflow_id [simulation::template::clone \
                            -workflow_id $workflow_id \
                             -package_key "simulation" \
                             -object_id [ad_conn package_id] \
                             -array new_workflow_array]


        # Proceed to the task page
        ad_returnredirect [export_vars -base map-tasks {workflow_id}]
        ad_script_abort

    }
