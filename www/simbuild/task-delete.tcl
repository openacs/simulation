ad_page_contract {
    Delete a task

} {
    action_id:integer
    {return_url ""}
}

set workflow_id [workflow::action::get_element -action_id $action_id -element workflow_id]
permission::require_write_permission -object_id $workflow_id
simulation::action::edit -operation "delete" -action_id $action_id

if { [empty_string_p $return_url] } {
    set return_url [export_vars -base template-edit { workflow_id }]
}
ad_returnredirect $return_url
