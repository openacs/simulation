ad_page_contract {
    Delete a task

} {
    action_id:integer
    {return_url "sim-template-list"}
}

workflow::action::fsm::delete -action_id $action_id

ad_returnredirect $return_url