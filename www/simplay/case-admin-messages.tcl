ad_page_contract {
    List of messages for a case
} {
    case_id:integer
    role_id:integer
}

set workflow_id [simulation::case::get_element -case_id $case_id -element workflow_id]
set simulation_name [simulation::template::get_element -workflow_id $workflow_id -element pretty_name]
workflow::role::get -role_id $role_id -array role_array
simulation::case::get -case_id $case_id -array case_array

set title [_ simulation.case_admin_page_title]
set context [list [list . [_ simulation.SimPlay]] [list [export_vars -base case-admin { case_id }] [_ simulation.lt_Administer_case_prett]] [_ simulation.lt_Messages_for_role_pre]]

set user_id [ad_conn user_id]
