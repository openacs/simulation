ad_page_contract {
    Set the initial action of a workflow.
} {
    action_id:integer
    return_url
}

set row(initial_action_p) 1

workflow::action::edit \
    -action_id $action_id \
    -array row

ad_returnredirect $return_url

