ad_page_contract {
    Start a simulation immediately and redirect
    to simplay.

    @author Peter Marklund
} {
    workflow_id:integer
}

simulation::template::force_start -workflow_id $workflow_id

ad_returnredirect "../simplay"
return
