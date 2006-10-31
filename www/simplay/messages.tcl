ad_page_contract {
    List of messages for a case
} {
    case_id:integer
    role_id:integer
}

#PERM: user should be a participant in sim

set workflow_id [simulation::case::get_element -case_id $case_id -element workflow_id]
set simulation_name [simulation::template::get_element -workflow_id $workflow_id -element pretty_name]

set title "Messages"
set context [list [list . "SimPlay"] [list [export_vars -base case { case_id role_id }] "$simulation_name"] $title]

set user_id [ad_conn user_id]
set package_id [ad_conn package_id]
set section_uri [apm_package_url_from_id $package_id]simplay/
set trash_url [export_vars -base ${section_uri}trash { case_id role_id }]
