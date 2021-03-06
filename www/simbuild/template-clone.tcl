ad_page_contract {
    Clone new simulation
} {
    workflow_id:integer
}

permission::require_permission -object_id [ad_conn package_id] -privilege sim_template_create

workflow::get -workflow_id $workflow_id -array workflow_array

set page_title "Clone $workflow_array(pretty_name)"
set context [list [list "." "SimBuild"] $page_title]
