ad_page_contract {
    This page allows users to choose which group to join.  It is only relevant for simulations with casting type of group.
} {
    {workflow_id:integer ""}
}

# TODO: check that user is enrolled and that casting_type is not auto_cast

set title "Join a Case in Simulation SIMNAME"
set context [list $title]
set user_id [ad_conn user_id]
set package_id [ad_conn package_id]
set section_uri [apm_package_url_from_id $package_id]simplay/
