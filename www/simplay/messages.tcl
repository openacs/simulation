ad_page_contract {
    List of messages for a case
} {
    case_id:integer
}

set workflow_id [simulation::case::get_element -case_id $case_id -element workflow_id]
set simulation_name [simulation::template::get_element -workflow_id $workflow_id -element pretty_name]

set title "Messages"
set context [list [list . "SimPlay"] [list [export_vars -base case { case_id }] "$simulation_name"] $title]

set user_id [ad_conn user_id]
