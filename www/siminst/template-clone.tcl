ad_page_contract {
    Clone new simulation
} {
    workflow_id:integer
}

workflow::get -workflow_id $workflow_id -array workflow_array

set page_title "Clone $workflow_array(pretty_name)"
set context [list [list "." "SimInst"] $page_title]
