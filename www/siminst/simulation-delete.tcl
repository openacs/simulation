ad_page_contract {
    Delete a simulation
} {
    workflow_id:integer
}

set page_title "Delete simulation"
set context [list $page_title]
set package_id [ad_conn package_id]

simulation::template::delete -workflow_id $workflow_id

ad_returnredirect .
