ad_page_contract {
    Update task enabled in state.
} {
    action_id:integer
    state_id:integer
    {enabled_p:boolean t}
    {assigned_p:boolean t}
    {return_url {}}
}

set workflow_id [workflow::action::get_element \
		     -action_id $action_id \
		     -element workflow_id]

permission::require_write_permission -object_id $workflow_id

workflow::action::fsm::set_enabled_in_state \
    -action_id $action_id \
    -state_id $state_id \
    -enabled=[template::util::is_true $enabled_p] \
    -assigned=[template::util::is_true $assigned_p]

if { [empty_string_p $return_url] } {    
    set return_url [export_vars -base template-edit { workflow_id }]
}

# Let's mark this template edited
set sim_type "dev_template"

ad_returnredirect [export_vars -base "template-sim-type-update" { workflow_id sim_type return_url }]