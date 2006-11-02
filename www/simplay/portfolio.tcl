ad_page_contract {
    List of sim_props for the role/case.
} {
    case_id:integer
    role_id:integer
    portfolio_orderby:optional
    {bin_p:integer 0}
}

set deleted_p $bin_p
set show_actions_p [ad_decode $deleted_p 1 0 1]
set workflow_id [simulation::case::get_element -case_id $case_id -element workflow_id]
set simulation_name [simulation::template::get_element -workflow_id $workflow_id -element pretty_name]

set title [ad_decode $deleted_p 1 [_ simulation.Recycle_Bin] [_ simulation.Portfolio]]
set context [list [list . [_ simulation.SimPlay]] [list [export_vars -base case { case_id role_id }] "$simulation_name"] $title]

set user_id [ad_conn user_id]
set package_id [ad_conn package_id]
set section_uri [apm_package_url_from_id $package_id]simplay/
set bin_p [ad_decode $bin_p 1 "0" "1"]
set recycle_bin_url [export_vars -base ${section_uri}portfolio { case_id role_id bin_p }]

if { ![exists_and_not_null portfolio_orderby] } {
    set portfolio_orderby 0
}

set bin_title [ad_decode $deleted_p 1 [_ simulation.back_to_portfolio] [_ simulation.Recycle_Bin]]