ad_page_contract {
    Delete a task

} {
    action_id:integer
    {return_url "."}
}

permission::require_write_permission -object_id $action_id
workflow::action::fsm::delete -action_id $action_id

ad_returnredirect $return_url