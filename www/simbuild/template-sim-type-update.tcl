ad_page_contract {
    Mark a template ready for use
} {
    workflow_id:integer
    {sim_type "ready_template"}
    {return_url {[export_vars -base "template-edit" { workflow_id }]}}
}

permission::require_write_permission -object_id $workflow_id

set row(sim_type) $sim_type

simulation::template::edit \
    -workflow_id $workflow_id \
    -array row

ad_returnredirect $return_url
