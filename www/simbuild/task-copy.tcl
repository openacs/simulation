ad_page_contract {
    Copy (clone) a task.

    @author Peter Marklund
} {
    action_id:integer
    {return_url ""}
    
}

simulation::action::clone -action_id $action_id

if { [empty_string_p $return_url] } {
    set return_url [export_vars -base template-edit { workflow_id }]
}
ad_returnredirect $return_url
