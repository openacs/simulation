ad_page_contract {
    Delete a state

} {
    state_id:integer
    {return_url ""}
}

set workflow_id [workflow::state::fsm::get_element -state_id $state_id -element workflow_id]
permission::require_write_permission -object_id $workflow_id
workflow::state::fsm::edit -operation "delete" -state_id $state_id

if { [empty_string_p $return_url] } {
    set return_url [export_vars -base template-edit { workflow_id }]
}
ad_returnredirect $return_url
