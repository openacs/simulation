ad_page_contract {
    Delete a task

} {
    action_id:integer
    {return_url ""}
}

if { ![exists_and_not_null workflow_id] } {
    set workflow_id [workflow::action::get_element \
		     -action_id $action_id \
		     -element workflow_id]
}

permission::require_write_permission -object_id $workflow_id
simulation::action::edit -operation "delete" -action_id $action_id

if { [empty_string_p $return_url] } {
    set return_url [export_vars -base template-edit { workflow_id }]
}

# Let's mark this template edited
set sim_type "dev_template"

ad_returnredirect [export_vars -base "template-sim-type-update" { workflow_id sim_type return_url }]