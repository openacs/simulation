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

set name_default "New Simulation based on $old_name"

ad_form \
    -name template \
    -export { workflow_id } \
    -form {
        {pretty_name:text
            {label "Simulation name"}
            {value $name_default}
            {html {size 60}}
            {help_text "Please choose a new name for your new simulation"}
        }
    } -on_submit {
        # Check that pretty_name is unique

        set unique_p [simulation::template::pretty_name_unique_p \
                          -package_id [ad_conn package_id] \
                          -pretty_name $pretty_name]

        if { !$unique_p } {
            form set_error template pretty_name "This name is already used by another simulation"
            break
        }

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
        ad_returnredirect [export_vars -base wizard { workflow_id }]
        ad_script_abort

    }
