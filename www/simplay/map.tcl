ad_page_contract {
    Simplay home page for a user in one case.
} {
    case_id:integer,notnull
    role_id:integer,notnull
    portfolio_orderby:optional
}

simulation::case::assert_user_may_play_role \
  -case_id $case_id -role_id $role_id

set workflow_id [simulation::case::get_element -case_id $case_id \
                   -element workflow_id]

set simulation_name [simulation::template::get_element \
                      -workflow_id $workflow_id -element pretty_name]

set sim_title [_ simulation.simulation_name]
set title "Sieberdam Map"
set context [list [list . [_ simulation.SimPlay]] [list [export_vars -base case {case_id role_id }] $sim_title] $title]
set user_id [ad_conn user_id]
set package_id [ad_conn package_id]
set section_uri [apm_package_url_from_id $package_id]simplay/

set messages_url [export_vars -base messages { case_id role_id }]