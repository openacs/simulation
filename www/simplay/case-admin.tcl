ad_page_contract {
    This page allows users to choose which group to join.  It is only relevant for simulations with casting type of group.
} {
    {case_id:integer ""}
}

set title "Administer"
set context [list [list . "SimPlay"] [list [export_vars -base case { case_id }] "Case CASENAME"] $title]
set user_id [ad_conn user_id]
set package_id [ad_conn package_id]
set section_uri [apm_package_url_from_id $package_id]simplay/
