ad_page_contract {
    List of tasks for a case
} {
    case_id:integer
    role_id:integer
}

set workflow_id [simulation::case::get_element -case_id $case_id -element workflow_id]
set simulation_name [simulation::template::get_element -workflow_id $workflow_id -element pretty_name]

set title [_ simulation.Tasks]
set context [list [list . [_ simulation.SimPlay]] [list [export_vars -base case { case_id role_id }] "$simulation_name"] $title]

set user_id [ad_conn user_id]
