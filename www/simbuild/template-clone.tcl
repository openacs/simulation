ad_page_contract {
    Clone new simulation
} {
    workflow_id:integer
}

permission::require_permission -object_id [ad_conn package_id] -privilege sim_template_create

workflow::get -workflow_id $workflow_id -array workflow_array

set page_title "Clone $workflow_array(pretty_name)"

set context [list [list "." "SimBuild"] $page_title]

set pretty_name "Clone of $workflow_array(pretty_name)"

ad_form -name clone -export { workflow_id } -edit_buttons [list [list "Clone" ok]] -form {
    {pretty_name:text
        {label "Name"}
        {html {size 50}}
    }
} -on_request {

} -on_submit {
    set new_workflow_array(pretty_name) $pretty_name
    set new_workflow_array(short_name) {}
    
    simulation::template::clone \
        -workflow_id $workflow_id \
        -package_key "simulation" \
        -object_id [ad_conn package_id] \
        -array new_workflow_array

    ad_returnredirect .
    ad_script_abort
}

