ad_page_contract {
    Update task enabled in state.
} {
    action_id:integer
    state_id:integer
    {enabled_p:boolean t}
    {assigned_p:boolean t}
    {return_url {}}
}

workflow::action::fsm::set_enabled_in_state \
    -action_id $action_id \
    -state_id $state_id \
    -enabled=[template::util::is_true $enabled_p] \
    -assigned=[template::util::is_true $assigned_p]

if { [empty_string_p $return_url] } {
    set workflow_id [workflow::action::get_element \
                         -action_id $action_id \
                         -element workflow_id]
    
    set return_url [export_vars -base template-edit { workflow_id }]
}

ad_returnredirect $return_url
