ad_page_contract {
    List of sim_props for the role/case.
} {
    case_id:integer
    role_id:integer
}

set workflow_id [simulation::case::get_element -case_id $case_id -element workflow_id]
set simulation_name [simulation::template::get_element -workflow_id $workflow_id -element pretty_name]
workflow::role::get -role_id $role_id -array role_array
simulation::case::get -case_id $case_id -array case_array

set title [_ simulation.lt_Portfolio_for_role_ar]
set context [list [list . [_ simulation.SimPlay] ] \
                  [list [export_vars -base case-admin { case_id }] \
                    [_ simulation.lt_Administer_case_array]] \
                  [_ simulation.lt_Portfolio_for_role_ar_1]]

set user_id [ad_conn user_id]
set package_id [ad_conn package_id]
set section_uri [apm_package_url_from_id $package_id]simplay/
